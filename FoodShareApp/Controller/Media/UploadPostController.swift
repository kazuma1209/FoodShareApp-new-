//
//  UploadPostController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/08.
//

import UIKit

protocol UploadPostControllerDelegate: AnyObject {
    func controllerDidFinishUploadingPost(_ controller: UploadPostController)
}

class UploadPostController:UIViewController{
    //MARK: -プロパティー
    
    weak var delegate:UploadPostControllerDelegate?
    
    var currentUser:User?
    
    var selectedImage:UIImage?{
        didSet{
            photoImageView.image = selectedImage
        }
    }
    
    private let photoImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var captionTextView:InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "写真についてのキャプションを書こう！"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1
        
        tv.delegate = self
        tv.placeholderShouldCenter = false
        return tv
    }()
    
    private let charactorCountLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()
    
    //MARK: -ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: -セレクター
    @objc func didTapCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDone(){
        guard let image = selectedImage else {return}
        guard let caption = captionTextView.text else {return}
        guard let user = currentUser else {return}
        
        showLoader(true)
        
        PostService.uploadPost(caption: caption, image: image, user: user) { error in
            self.showLoader(false)
            if let error = error {
                print("DEBUG: 投稿に失敗　-> \(error.localizedDescription)")
                return
            }
            
            self.delegate?.controllerDidFinishUploadingPost(self)
        }
    }
    
    //MARK: -ヘルパー
    
    //文字数の設定
    func checkMaxLength(_ textView:UITextView){
        if (textView.text.count) > 100{
            textView.deleteBackward()
        }
    }
    
    func configureUI(){
        view.backgroundColor = .mainBackgroundColor
        
        navigationItem.title = "投稿"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "やめる！",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "投稿！",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapDone))
        
        view.addSubview(photoImageView)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 8)
        photoImageView.centerX(inView: view)
        photoImageView.layer.cornerRadius = 10
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: photoImageView.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,
                               paddingTop: 16,paddingLeft: 12,paddingRight: 12,height: 64)
        
        view.addSubview(charactorCountLabel)
        charactorCountLabel.anchor(bottom: captionTextView.bottomAnchor,right: captionTextView.rightAnchor,paddingBottom: -18,paddingRight: 1)

    }
}

//MARK: -UITextViewDelegate

extension UploadPostController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
        let count = textView.text.count
        charactorCountLabel.text = "\(count)/100"
        
    }
}
