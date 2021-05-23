//
//  PostService.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/08.
//
import UIKit
import Firebase

struct PostService {
    
    //MARK: 投稿する機能
    static func uploadPost(caption:String,image:UIImage,user:User,completion: @escaping(FireStoreCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption":caption,
                        "timestamp":Timestamp(date: Date()),
                        "likes":0,
                        "imageUrl":imageUrl,
                        "ownerUid":uid,
                        "ownerImageUrl":user.profileImageUrl,
                        "ownerUsername":user.username] as [String : Any]
            
            let docRef = COLLECTION_POSTS.addDocument(data: data,completion: completion)
            
            self.updateUserFeedAfterPost(postId: docRef.documentID)
        }
    }
    
    //MARK: 投稿の取得(タイムライン)
    static func fetchPosts(completion:@escaping([Post])->Void){
        COLLECTION_POSTS.order(by: "timestamp",descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {return}
            
            let posts = documents.map({Post(postId: $0.documentID, dictionary: $0.data())})
            completion(posts)
            
        }
    }
    
    //MARK: 投稿の取得(ユーザのプロフィール画面)
    static func fetchPosts(forUser uid:String,completion:@escaping([Post])->Void){
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {return}

            var posts = documents.map({Post(postId: $0.documentID, dictionary: $0.data())})
            
            posts.sort(by: {$0.timestamp.seconds > $1.timestamp.seconds})

            
            completion(posts)
        }
    }
    
    //MARK: 投稿の取得(お知らせ画面のタップ)
    static func fetchPost(withPostId postId:String,completion:@escaping(Post)->Void){
        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else {return}
            guard let data = snapshot.data() else {return}
            let post = Post(postId: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    //MARK:　お気に入り機能
    static func likePost(post:Post,completion:@escaping(FireStoreCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes":post.likes + 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]) { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:],completion: completion)
        }
    }
    
    //MARK:　お気に入り取り消し機能
    static func unlikePost(post:Post,completion:@escaping(FireStoreCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        guard post.likes > 0 else {return}

        COLLECTION_POSTS.document(post.postId).updateData(["likes":post.likes - 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    //MARK: いいねしているかどうか確かめる機能
    static func checkIfUserLikedPost(post:Post,completion:@escaping(Bool)->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}

        COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).getDocument { snapshot, _ in
            guard let didLike = snapshot?.exists else {return}
            
            completion(didLike)
        }
    }
    
    //MARK: feedにおける投稿の取得
    static func fetchFeedPosts(completion: @escaping([Post])->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        var posts = [Post]()
        
        COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    
                    posts.sort(by: {$0.timestamp.seconds > $1.timestamp.seconds})

                    completion(posts)
                }
            })
        }
    }
    
    //MARK: フォローした後，そのフォローした人の投稿を自分のuser-feedに加える機能
    static func updateUserFeedAfterFollowing(user:User,didFollow:Bool){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {return}
            
            let docIDs = documents.map({$0.documentID})
            
            docIDs.forEach { id in
                
                if didFollow{
                    COLLECTION_USERS.document(uid).collection("user-feed").document(id).setData([:])
                }else{
                    COLLECTION_USERS.document(uid).collection("user-feed").document(id).delete()
                }
                
                
            }
        }
    }
    
    //MARK: フォローしたユーザが新たに投稿した場合のデータをuser-feedに書き込む機能
    private static func updateUserFeedAfterPost(postId:String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {return}
            
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postId).setData([:])
            }
            
            COLLECTION_USERS.document(uid).collection("user-feed").document(postId).setData([:])
        }
    }
    
    //MARK: 投稿を削除する機能
    static func deletePost(_ postId: String, completion: @escaping(FireStoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //まずはポストのコレクションのドキュメントからpost-likes（いいねしている人）のuidを取得します。
        COLLECTION_POSTS.document(postId).collection("post-likes").getDocuments { snapshot, _ in
            guard let uids = snapshot?.documents.map({ $0.documentID }) else { return }
            //その後、そのuidをユーザのコレクションのドキュメントから特定し、そのユーザが持っているいいねした情報（user-likes）から削除する投稿（postId）を削除します。
            uids.forEach({ COLLECTION_USERS.document($0).collection("user-likes").document(postId).delete() })
        }
        
        COLLECTION_POSTS.document(postId).delete { _ in
            //followersのコレクションのドキュメントから、現在のユーザのフォロワー（user-followers）のuidを取得します。
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
                guard let uids = snapshot?.documents.map({ $0.documentID }) else { return }
                //そしてそのuidからユーザを特定し、削除する投稿（postId）をそのユーザのuser-feedから削除します
                uids.forEach({ COLLECTION_USERS.document($0).collection("user-feed").document(postId).delete() })
                //そしてそのユーザのお知らせ（user-notification）からも削除する投稿（postId）とイコールのものを見つけて削除します。
                let notificationQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
                notificationQuery.whereField("postId", isEqualTo: postId).getDocuments { snapshot, _ in
                    guard let documents = snapshot?.documents else { return }
                    documents.forEach({ $0.reference.delete(completion: completion) })
                }
            }
        }
    }
}
