//
//  CommentInputAccesoryView.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/10.
//

import UIKit

protocol CommentInputAccesoryViewDelegate:AnyObject {
    func inputView(_ inputView:CommentInputAccesoryView,wantsToUploadComment comment:String)
}

class CommentInputAccesoryView:UIView{
    
    //MARK: -プロパティー
    
    weak var delegate : CommentInputAccesoryViewDelegate?
    
    private let commentTextView:InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "テキストを入力"
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.isScrollEnabled = false
        tv.placeholderShouldCenter = true
        tv.backgroundColor = .mainBackgroundColor
        return tv
    }()
    
    private let postButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送信！", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handlePostTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: -ライフサイクル
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .mainBackgroundColor
        
        autoresizingMask = .flexibleHeight
        
        addSubview(postButton)
        postButton.anchor(top: topAnchor,right: rightAnchor,paddingRight: 8)
        postButton.setDimensions(height: 50, width: 50)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor,left: leftAnchor,bottom: safeAreaLayoutGuide.bottomAnchor,right: postButton.leftAnchor,
                               paddingTop: 8,paddingLeft: 8,paddingBottom: 8,paddingRight: 8)
        
        let divider = UIView()
        divider.backgroundColor = .lightGray
        addSubview(divider)
        divider.anchor(top: topAnchor,left: leftAnchor,right: rightAnchor,height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    //MARK: -セレクター
    @objc func handlePostTapped(){
        delegate?.inputView(self, wantsToUploadComment: commentTextView.text)
    }
    
    //MARK: -ヘルパー
    
    //送信ボタンを押した後、入力欄のテキストを消す
    func clearCommentTextView(){
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
    }
}
