//
//  FeedCell.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/02.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell:FeedCell,wantsToShowCommentsFor post:Post)
    func cell(_ cell:FeedCell,didLike post:Post)
    func cell(_ cell:FeedCell,wantsToShowProfileFor uid:String)
    func cell(_ cell: FeedCell, wantsToShowOptionsForPost post: Post)
}

class FeedCell:UICollectionViewCell{
    //MARK: -プロパティー
    
    var viewModel:PostViewModel?{
        didSet{
            configure()
        }
    }
    
    weak var delegate:FeedCellDelegate?
    
    private lazy var profileImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private lazy var usernameButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(showUserProfile), for: .touchUpInside)
        return button
    }()
    
    private let postImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var likeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "banana"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "コメント-1"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "シェア"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let likesLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private let captionLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let postTimeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(imageLiteralResourceName: "投稿編集"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
        return button
    }()
    //MARK: -ライフサイクル
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,left: leftAnchor,paddingTop: 12,paddingLeft: 12)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40/2
        
        addSubview(usernameButton)
        usernameButton.centerY(inView: profileImageView,leftAnchor: profileImageView.rightAnchor,paddingLeft: 8)
        
        addSubview(optionsButton)
        optionsButton.centerY(inView: profileImageView)
        optionsButton.anchor(right: rightAnchor, paddingRight: 12)
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor,left: leftAnchor,right: rightAnchor,
                             paddingTop: 8,paddingLeft: 5,paddingRight: 5)
        postImageView.layer.cornerRadius = 50
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButton()
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor,left: leftAnchor,paddingTop: -4,paddingLeft: 15)

        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor,left: leftAnchor,paddingTop: 8,paddingLeft: 15)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor,left: leftAnchor,paddingTop: 8,paddingLeft: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -セレクター
    @objc func showOptions(){
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowOptionsForPost: viewModel.post)
    }
    
    @objc func showUserProfile(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(self, wantsToShowProfileFor: viewModel.post.ownerUid)
    }
    
    @objc func didTapComment(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(self, wantsToShowCommentsFor: viewModel.post)
    }
    
    @objc func didTapLike(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(self, didLike: viewModel.post)
    }
    //MARK: -ヘルパー
    
    func configure(){
        guard let viewModel = viewModel else {return}
        captionLabel.text = viewModel.caption
        postImageView.sd_setImage(with: viewModel.imageUrl)
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        usernameButton.setTitle(viewModel.username, for: .normal)
        likesLabel.text = viewModel.likesLabelText
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        postTimeLabel.text = viewModel.timestampString
    }
    
    func configureActionButton(){
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor,left: leftAnchor,paddingLeft: 10,width: 120,height: 50)
    }
    
}
