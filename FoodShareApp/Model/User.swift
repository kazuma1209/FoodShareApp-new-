//
//  User.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/06.
//

import Foundation
import Firebase

struct User {
    let email:String
    var fullname:String
    var profileImageUrl:String
    var username:String
    let uid:String
    
    var isFollowed = false
    
    var status:UserStatus!
    
    var isCurrentUser:Bool{
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(dictionary:[String:Any]){
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        self.status = UserStatus(followers: 0, following: 0, posts: 0)

    }
}
//MARK: ユーザの情報(フォロワー、フォロー中の数と投稿数)
struct UserStatus {
    let followers:Int
    let following:Int
    let posts:Int
}
