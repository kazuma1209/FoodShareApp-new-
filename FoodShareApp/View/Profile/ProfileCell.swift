//
//  ProfileCell.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/05.
//

import UIKit

class ProfileCell:UICollectionViewCell{
    //MARK: -プロパティー
    
    var viewModel:PostViewModel?{
        didSet{
            configure()
        }
    }
    
    private let postImageView:UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "ご飯")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    //MARK: -ライフサイクル
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
        
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -ヘルパー
    func configure(){
        guard let viewModel = viewModel else {return}
        
        postImageView.sd_setImage(with: viewModel.imageUrl)
    }

}
