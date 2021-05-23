//
//  LoginController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/03.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authnticationDidComplete()//①delegateの準備(AuthenticationDelegate:authnticationDidComplete)
}

class LoginController:UIViewController{
    
    //MARK: -プロパティー
    
    private var viewModel = LoginViewModel()
    
    weak var delegate:AuthenticationDelegate?//②delegateの宣言(AuthenticationDelegate:authnticationDidComplete)
    
    private let iconImage:UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "タイトルロゴ"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField:UITextField = {
        let tf = CustomTextField(placeholder: "メールアドレス")
        return tf
    }()
    
    private let passwordTextField:UITextField = {
        let tf = CustomTextField(placeholder: "パスワード")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ログイン！", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton:UIButton = {
        let button = UIButton(type: .system)
        button.attributeTitle(firstPart: "パスワードを忘れた", secondPart: "ヘルプへ")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        button.attributeTitle(firstPart: "アカウントを持っていない", secondPart: "ここをクリック!")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()

    //MARK: -ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObserver()
        
    }
    //MARK: -セレクター
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        AuthService.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error{
                print("DEBUG: ログインに失敗->\(error.localizedDescription)")
                return
            }
            self.delegate?.authnticationDidComplete()//③delegateを呼び出す(AuthenticationDelegate:authnticationDidComplete)
            
        }
    }
    
    @objc func handleShowSignUp(){
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField){
        if sender == emailTextField{
            viewModel.email = sender.text
        }else{
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleShowResetPassword(){
        let controller = ResetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
        
    }
    //MARK: -ヘルパー
    func configureUI(){
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton,forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,
                     paddingTop: 32,paddingLeft: 32,paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        
    }
    func configureNotificationObserver(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

}

//MARK: -FormViewModek
extension LoginController:FormViewModel{
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}

//MARK: -ResetPasswordControllerDelegate
extension LoginController:ResetPasswordControllerDelegate{
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "成功", message: "あなたのメールアドレスにパスワードをリセットするためのリンクを送りました。")
    }
}
