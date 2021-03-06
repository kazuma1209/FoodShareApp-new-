//
//  NotificationController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/01.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController:UITableViewController{
    //MARK: -プロパティー
    
    private var notifications = [Notification](){
        didSet{
            tableView.reloadData()
        }
    }
    
    private let refresher = UIRefreshControl()

    //MARK: -ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchNotifications()
    }
    
    //MARK: -API
    func fetchNotifications(){
        NotificationService.fetchNotification { notifications in
            self.notifications = notifications
            self.checkIfUserIsFollowed()
        }
    }
    
    func checkIfUserIsFollowed(){
        notifications.forEach { notification in
            guard notification.type == .follow else {return}
            UserService.checkIfUserIsFollowed(uid: notification.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: {$0.id == notification.id}){
                    self.notifications[index].userIsFollowed = isFollowed
                }
            }
        }
    }
    //MARK: -セレクター
    @objc func handleRefresh(){
        notifications.removeAll()
        fetchNotifications()
        refresher.endRefreshing()
    }
    //MARK: -ヘルパー
    func configureTableView(){
        view.backgroundColor = .mainBackgroundColor
        navigationItem.title = "お知らせ"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView(frame: .zero)
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
    }
}

//MARK: -UITableViewDataSource
extension NotificationController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.delegate = self
        return cell
    }
}

//MARK: -UITableViewDelegate
extension NotificationController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        UserService.fetchUser(withUid: notifications[indexPath.row].uid) { user in
            self.showLoader(false)
            
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
    }
}
//MARK: -NotificationCellDelegate
extension NotificationController:NotificationCellDelegate{
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        showLoader(true)

        UserService.followUser(uid: uid) { _ in
            self.showLoader(false)

            cell.viewModel?.notification.userIsFollowed.toggle()
        }

    }
    
    func cell(_ cell: NotificationCell, wantsToUnFollow uid: String) {
        showLoader(true)

        UserService.unfollowUser(uid: uid) { _ in
            self.showLoader(false)

            cell.viewModel?.notification.userIsFollowed.toggle()
        }

    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        showLoader(true)

        PostService.fetchPost(withPostId: postId) { post in
            self.showLoader(false)

            let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
}
