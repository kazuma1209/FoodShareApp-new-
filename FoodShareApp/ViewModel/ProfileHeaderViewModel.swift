//
//  ProfileHeaderViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/06.
//

import Foundation
import UIKit

struct ProfileHeaderViewModel {
    let user:User
    
    var fullname:String{
        return user.fullname
    }
    
    var profileImageUrl:URL?{
        return URL(string: user.profileImageUrl)
    }
    
    
    var followButtonText:String{
        if user.isCurrentUser{
            return "プロフィールを編集"
        }
        
        return user.isFollowed ? "フォロー中" : "フォローする！"
    }
    
    var followButtonBackgroundColor:UIColor{
        return user.isCurrentUser ? .mainBackgroundColor : .orange
    }
    
    var followButtonTextColor:UIColor{
        return user.isCurrentUser ? .black : .mainBackgroundColor
    }
    
    var numberOfFollowers:NSAttributedString{
        return attributeStatText(value: user.status.followers, label: "フォロワー")
    }
    
    var numberOfFollowing:NSAttributedString{
        return attributeStatText(value: user.status.following, label: "フォロー中")
    }
    
    var numberOfPost:NSAttributedString{
        return attributeStatText(value: user.status.posts, label: "投稿")
    }
    
    init(user:User){
        self.user = user
    }
    
    func attributeStatText(value:Int,label:String)->NSAttributedString{
        let attributeText = NSMutableAttributedString(string: "\(value)\n", attributes: [.font:UIFont.boldSystemFont(ofSize: 14)])
        attributeText.append(NSAttributedString(string: label, attributes: [.font:UIFont.systemFont(ofSize: 14),.foregroundColor:UIColor.lightGray]))
        
        return attributeText
    }
}
