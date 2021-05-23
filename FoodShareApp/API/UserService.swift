//
//  UserService.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/06.
//

import Firebase

typealias FireStoreCompletion = (Error?)->Void

struct UserService {
    
    //MARK: ユーザ情報の取得(自分)
    static func fetchUser(withUid uid:String,completion: @escaping(User)->Void){
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else {return}
            
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    //MARK: ユーザ情報の取得(複数)
    static func fetchUsers(completion:@escaping([User])->Void){
        COLLECTION_USERS.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {return}
            //$0はリスト内のそれぞれの要素を意味する
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            completion(users)
        }
    }
    
    //MARK: フォロー機能
    static func followUser(uid:String,completion: @escaping(FireStoreCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:],completion: completion)
        }
    }
    
    //MARK: フォロー解除機能
    static func unfollowUser(uid:String,completion: @escaping(FireStoreCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
        }
    }
    
    //MARK: フォローしているか確かめる機能
    //(SearchControllerの画面遷移時に、フォロー、アンフォローのUIを更新するため)
    static func checkIfUserIsFollowed(uid:String,completion:@escaping(Bool)->Void){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            //データが存在するかどうか
            guard let isFollowed = snapshot?.exists else {return}
            completion(isFollowed)
        }
    }
    
    //MARK: ユーザの情報(フォロワー、フォロー中の数と投稿数)を取得する機能
    static func fetchUserStatus(uid:String,completion:@escaping(UserStatus)->Void){
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let followers = snapshot?.documents.count ?? 0
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
                let following = snapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid",isEqualTo: uid).getDocuments { snapshot, _ in
                    let posts = snapshot?.documents.count ?? 0
                    completion(UserStatus(followers: followers, following: following, posts: posts))

                }
            }
        }
    }
    //MARK: プロフィール画像の更新
    static func updateProfileImage(forUser user: User, image: UIImage, completion: @escaping(String?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
                
        ImageUploader.uploadImage(image: image) { profileImageUrl in
            let data = ["profileImageUrl": profileImageUrl]
            
            COLLECTION_USERS.document(uid).updateData(data) { error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid).getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    let data = ["ownerImageUrl": profileImageUrl]
                    documents.forEach({ COLLECTION_POSTS.document($0.documentID).updateData(data) })
                }
                                
                completion(profileImageUrl, nil)
            }
        }
    }
    //MARK: 変更内容の保存
    static func saveUserData(user: User, completion: @escaping(FireStoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = ["email": user.email,
                                   "fullname": user.fullname,
                                   "profileImageUrl": user.profileImageUrl,
                                   "uid": uid,
                                   "username": user.username]
        
        COLLECTION_USERS.document(uid).setData(data, completion: completion)
    }
}
