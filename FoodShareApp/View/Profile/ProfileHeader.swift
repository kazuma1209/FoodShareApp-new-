//
//  ProfileHeader.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/05.
//

import UIKit
import SDWebImage

protocol ProfileHeaderDelegate: AnyObject {
    func header(_ profileHeader:ProfileHeader,didTapActionButtonFor user:User)

}

class ProfileHeader:UICollectionReusableView{
    //MARK: -プロパティー
    
    var viewModel:ProfileHeaderViewModel?{
        didSet{
            configure()
        }
    }
    
    weak var delegate:ProfileHeaderDelegate?
    
    private let profileImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let editProfileFollowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("読み込み中...", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.borderWidth = 2
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var postsLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followersLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followingLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let gridButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "記事"), for: .normal)
        button.tintColor = .orange
        return button
    }()
    
    let listButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    //MARK: -ライフサイクル
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,left: leftAnchor,paddingTop: 16,paddingLeft: 12)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80/2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor,left: leftAnchor,paddingTop: 12,paddingLeft: 12)
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: nameLabel.bottomAnchor,left: leftAnchor,right: rightAnchor,
                                       paddingTop: 16,paddingLeft: 24,paddingRight: 24)
        
        let stack = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.rightAnchor,right: rightAnchor,paddingLeft: 12,paddingRight: 12,height: 50)
        
        let divider = UIView()
        divider.backgroundColor = .lightGray
        
        addSubview(divider)
        divider.anchor(left:leftAnchor,bottom: bottomAnchor,right: rightAnchor,height: 3)



    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -セレクター
    @objc func handleEditProfileFollowTapped(){
        guard let viewModel = viewModel else {return}
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }
    
    //MARK: -ヘルパー
    
    func configure(){
        guard let viewModel = viewModel else {return}
                
        nameLabel.text = viewModel.fullname
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        
        editProfileFollowButton.setTitle(viewModel.followButtonText, for: .normal)
        editProfileFollowButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
        editProfileFollowButton.backgroundColor = viewModel.followButtonBackgroundColor
        
        postsLabel.attributedText = viewModel.numberOfPost
        followersLabel.attributedText = viewModel.numberOfFollowers
        followingLabel.attributedText = viewModel.numberOfFollowing
    }
    
    
}

