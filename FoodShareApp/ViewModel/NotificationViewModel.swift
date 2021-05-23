//
//  NotificationViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/13.
//

import UIKit
//MARK: NotificationCellに必要な要素

struct NotificationViewModel {
    var notification:Notification
    
    init(notification:Notification){
        self.notification = notification
    }
    
    var postImageUrl:URL?{
        return URL(string: notification.postImageUrl ?? "")
    }
    
    var profileImageUrl:URL?{
        return URL(string: notification.userProfileImageUrl)
    }
    
    var timestampString:String?{
        let fomatter = DateComponentsFormatter()
        fomatter.allowedUnits = [.second,.minute,.hour,.day,.weekOfMonth]
        fomatter.maximumUnitCount = 1
        fomatter.unitsStyle = .abbreviated
        return fomatter.string(from: notification.timestamp.dateValue(),to: Date())
    }
    
    var notificationMessage:NSAttributedString{
        
        let username = notification.username
        let message = notification.type.notificationMessage
        
        
        let attributeText = NSMutableAttributedString(string: username,attributes: [.font:UIFont.boldSystemFont(ofSize: 14)])
        attributeText.append(NSAttributedString(string: message, attributes: [.font:UIFont.systemFont(ofSize: 14)]))
        attributeText.append(NSAttributedString(string: "\n\(timestampString ?? "")", attributes: [.font:UIFont.systemFont(ofSize: 12),.foregroundColor:UIColor.lightGray]))
        
        return attributeText
        
    }
    
    var shouldHidePostImage:Bool{
        return self.notification.type == .follow
    }
    
    var followButtonText:String{
        return notification.userIsFollowed ? "フォロー中" : "フォロー！"
    }
    
    var followButtonBackgroundColor:UIColor{
        return notification.userIsFollowed ? .mainBackgroundColor : .orange
    }
    
    var followButtonTextColor:UIColor{
        return notification.userIsFollowed ? .black : .white
    }
    
}
