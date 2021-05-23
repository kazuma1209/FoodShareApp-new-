//
//  FeedController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/01.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedController:UICollectionViewController{
    
    //MARK: -プロパティー
    
    private var posts = [Post](){
        didSet{
            collectionView.reloadData()
        }
    }
    
    var post:Post?{
        didSet{
            collectionView.reloadData()
        }
    }

    //MARK: -ライフサイクル

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchPosts()
        
        if post != nil{
            checkIfUserLikedPosts()
        }
    }
    
    
    //MARK: -セレクター
    
    @objc func showMessages(){
        let controller = ConversationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleRefresh(){
        posts.removeAll()
        fetchPosts()
    }
    
    @objc func handleLogOut(){
        
        do{
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }catch{
            print("DEBUG: ログアウト失敗")
        }
        
    }
    //MARK: -API
    func fetchPosts(){
        guard post == nil else {return}

//        PostService.fetchPosts { posts in
//
//            self.posts = posts
//            self.collectionView.refreshControl?.endRefreshing()
//            self.checkIfUserLikedPosts()
//        }
        
        PostService.fetchFeedPosts { posts in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.checkIfUserLikedPosts()
        }
    }
    
    func checkIfUserLikedPosts(){
        if let post = post{
            PostService.checkIfUserLikedPost(post: post) { didlike in
                self.post?.didLike = didlike
            }
        }else{
            posts.forEach { post in
                PostService.checkIfUserLikedPost(post: post) { didLike in
                    if let index = self.posts.firstIndex(where: {$0.postId == post.postId}){
                        self.posts[index].didLike = didLike
                    }
                }
            }
        }
    }
    
    func deletePost(_ post: Post) {
        self.showLoader(true)
        
        PostService.deletePost(post.postId) { _ in
            self.showLoader(false)
            self.handleRefresh()
        }
    }
    
    
    //MARK: -ヘルパー
    
    func configureUI(){
        collectionView.backgroundColor = .mainBackgroundColor
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if post == nil{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "ログアウト", style: .done,
                                                                target: self, action: #selector(handleLogOut))
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "メール"), style: .plain, target: self,
                                                                action: #selector(showMessages))
            navigationItem.rightBarButtonItem?.tintColor = .black
        }
        
        navigationItem.title = "タイムライン"
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }

}
//MARK: -UICollectionViewDataSource
extension FeedController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        if let post = post{
            cell.viewModel = PostViewModel(post: post)
        }else {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
        }
        
        return cell
    }
}
//MARK: -UICollectionViewDelegateFlowLayout
extension FeedController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: width, height: height)
    }
}

//MARK: -FeedCellDelegate
extension FeedController:FeedCellDelegate{
    func cell(_ cell: FeedCell, wantsToShowOptionsForPost post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let deletePostAction = UIAlertAction(title: "投稿を削除する", style: .destructive) { _ in
            self.deletePost(post)
            self.showLoader(false)
        }
        
        let unfollowAction = UIAlertAction(title: "フォロー解除", style: .default) { _ in
            self.showLoader(true)

            UserService.unfollowUser(uid: post.ownerUid) { _ in
                self.showLoader(false)
            }
        }
        
        let followAction = UIAlertAction(title: "フォロー", style: .default) { _ in
            self.showLoader(true)
            
            UserService.followUser(uid: post.ownerUid) { _ in
                self.showLoader(false)
            }
        }
        
        let cancelAction =  UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            alert.addAction(deletePostAction)
        } else {
            UserService.checkIfUserIsFollowed(uid: post.ownerUid) { isFollowed in
                if isFollowed {
                    alert.addAction(unfollowAction)
                } else {
                    alert.addAction(followAction)
                }
            }
        }
        
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else {return}
        guard let user = tab.user else {return}
        
        cell.viewModel?.post.didLike.toggle()
        
        if post.didLike{
            PostService.unlikePost(post: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "banana"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.viewModel?.post.likes = post.likes - 1
            }
        }else{
            PostService.likePost(post: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "banana"), for: .normal)
                cell.likeButton.tintColor = .red
                cell.viewModel?.post.likes = post.likes + 1
                
                NotificationService.uploadNotification(toUid: post.ownerUid,fromUser: user, type: .like, post: post)
            }
        }
    }
    
}
