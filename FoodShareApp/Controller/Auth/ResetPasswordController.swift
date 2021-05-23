//
//  ResetPasswordController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/16.
//

import UIKit

protocol ResetPasswordControllerDelegate:AnyObject {
    func controllerDidSendResetPasswordLink(_ controller:ResetPasswordController)
}

class ResetPasswordController:UIViewController{
    
    //MARK: -プロパティー
    private var viewModel = ResetPasswordViewModel()
    
    private let emailTextField = CustomTextField(placeholder: "メールアドレス")
    
    weak var delegate : ResetPasswordControllerDelegate?
    
    var email:String?
    
    private let iconImage:UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "タイトルロゴ"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let resetPasswordButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("パスワードをリセット！", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    //MARK: -ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: -セレクター
    @objc func handleResetPassword(){
        guard let email = emailTextField.text else {return}
        
        showLoader(true)
        AuthService.resetPassword(withEmail: email) { error in
            if let error = error{
                self.showMessage(withTitle: "エラー", message: error.localizedDescription)
                self.showLoader(false)
                return
            }
            self.delegate?.controllerDidSendResetPasswordLink(self)
        }
    }
    
    @objc func textDidChange(sender:UITextField){
        if sender == emailTextField{
            viewModel.email = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleDismissal(){
        navigationController?.popViewController(animated: true)
    }
    //MARK: -ヘルパー
    func configureUI(){
        view.backgroundColor = .black
        
        emailTextField.text = email
        viewModel.email = email
        updateForm()
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,left: view.leftAnchor,paddingTop: 16,paddingLeft: 16)
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,resetPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,
                     paddingTop: 32,paddingLeft: 32,paddingRight: 32)
        
    }
    
}

//MARK: -FormViewModek
extension ResetPasswordController:FormViewModel{
    func updateForm() {
        resetPasswordButton.backgroundColor = viewModel.buttonBackgroundColor
        resetPasswordButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        resetPasswordButton.isEnabled = viewModel.formIsValid
    }
}

