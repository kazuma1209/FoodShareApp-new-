//
//  PostViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/09.
//

import UIKit

//MARK: FeedCellに必要な要素


struct PostViewModel {
    var post:Post
    
    var imageUrl:URL?{
        return URL(string: post.imageUrl)
    }
    
    var profileImageUrl:URL?{
        return URL(string: post.ownerImageUrl)
    }
    
    var username:String{
        return post.ownerUsername
    }
    
    var caption:String{
        return post.caption
    }
    
    var likes:Int{
        return post.likes
    }
    
    var likeButtonTintColor:UIColor{
        return post.didLike ? .red : .black
    }
    
    var likeButtonImage:UIImage{
        return #imageLiteral(resourceName: "banana")
    }
    
    var likesLabelText:String{
        return "\(post.likes) バナナ！"
    }
    
    var timestampString:String?{
        let fomatter = DateComponentsFormatter()
        fomatter.allowedUnits = [.second,.minute,.hour,.day,.weekOfMonth]
        fomatter.maximumUnitCount = 1
        fomatter.unitsStyle = .full
        return fomatter.string(from: post.timestamp.dateValue(),to: Date())
    }
    
    init(post:Post){
        self.post = post
    }
}
