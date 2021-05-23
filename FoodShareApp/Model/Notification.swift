//
//  Notification.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/13.
//

import Firebase
import UIKit

enum NotificationType:Int{
    case like
    case follow
    case comment
    
    var notificationMessage:String{
        switch self {
        case .like:
            return "がいいねしてくれました！"
        case .follow:
            return "がフォローしてくれました！"
        case .comment:
            return "がコメントしてくれました！"
        }
    }
}

struct Notification {
    let uid:String
    var postImageUrl:String?
    var postId:String?
    let timestamp:Timestamp
    let type:NotificationType
    let id:String?
    let userProfileImageUrl:String
    let username:String
    var userIsFollowed = false
    
    init(dictionary:[String:Any]){
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
    }
}
