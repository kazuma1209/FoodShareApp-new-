//
//  CommentViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/10.
//

import Foundation
import UIKit
//MARK: Commentを表示するのにに必要な要素

struct CommentViewModel {
    
    private let comment:Comment
    
    var profileImageUrl:URL?{
        return URL(string: comment.profileImageUrl)
    }
    
    var username:String{
        return comment.username
    }
    
    var commentText:String{
        return comment.commentText
    }
    
    init(comment:Comment){
        self.comment = comment
    }
    
    //MARK: 名前とコメントの表示について
    func commentLabelText()->NSAttributedString{
        let attributedString = NSMutableAttributedString(string: "\(comment.username) ",attributes: [.font:UIFont.boldSystemFont(ofSize: 14)])
        
        attributedString.append(NSAttributedString(string: comment.commentText,attributes: [.font:UIFont.systemFont(ofSize: 14)]))
        
        return attributedString
    }
    //MARK: コメントの大きさ設定
    func size(forWidth width:CGFloat)->CGSize{
        let label = UILabel()
        label.numberOfLines = 0
        label.text = comment.commentText
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
