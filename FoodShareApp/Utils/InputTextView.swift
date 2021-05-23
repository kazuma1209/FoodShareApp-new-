//
//  InputTextView.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/08.
//

import UIKit

//MARK: 入力するところの共通設定

class InputTextView:UITextView{
    //MARK: -プロパティー
    var placeholderText:String?{
        didSet{
            placeholderLabel.text = placeholderText
        }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    var placeholderShouldCenter = true{
        didSet{
            if placeholderShouldCenter{
                placeholderLabel.anchor(left: leftAnchor,right: rightAnchor,paddingLeft: 8)
                placeholderLabel.centerY(inView: self)
            }else{
                placeholderLabel.anchor(top: topAnchor,left: leftAnchor,paddingTop: 6,paddingLeft: 8)
            }
        }
    }
    
    //MARK: -ライフサイクル
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange),
                                               name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -セレクター
    @objc func handleTextDidChange(){
        //textが入力されるとplaceholderが消えるようにする
        placeholderLabel.isHidden = !text.isEmpty
    }

}
