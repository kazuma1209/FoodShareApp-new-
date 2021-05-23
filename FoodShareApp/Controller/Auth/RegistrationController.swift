//
//  RegistrationController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/03.
//

import UIKit

class RegistrationController:UIViewController{
    
    //MARK: -プロパティー
    
    private var viewModel = RegistrationViewModel()
    
    private var profileImage:UIImage?
    
    weak var delegate:AuthenticationDelegate?
    
    private let plusPhotoButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        return button
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
    
    private let fullnameTextField:UITextField = {
        let tf = CustomTextField(placeholder: "名前")
        tf.keyboardType = .default
        return tf
    }()
    
    private let usernameTextField:UITextField = {
        let tf = CustomTextField(placeholder: "ニックネーム")
        tf.keyboardType = .default
        return tf
    }()
    
    private let signUpButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("新規登録！", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let alreadyHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        button.attributeTitle(firstPart: "アカウントを持っている！", secondPart: "ここをクリック")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return button
    }()

    //MARK: -ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObserver()

    }
    //MARK: -セレクター
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField){
        if sender == emailTextField{
            viewModel.email = sender.text
        }else if sender == passwordTextField{
            viewModel.password = sender.text
        }else if sender == fullnameTextField{
            viewModel.fullname = sender.text
        }else{
            viewModel.username = sender.text
        }
        
        updateForm()
        
    }
    
    @objc func handleProfilePhotoSelect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUp(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullnameTextField.text else {return}
        guard let username = usernameTextField.text?.lowercased() else {return}
        guard let profileImage = self.profileImage else {return}
        
        let credenticals = AuthCredenticals(email: email, password: password,
                                            fullname: fullname, username: username,
                                            profileImage: profileImage)

        AuthService.registerUser(withCredenticals: credenticals) { error in
            if let error = error{
                print("DEBUG: 登録に失敗->\(error.localizedDescription)")
                return
            }
            
            self.delegate?.authnticationDidComplete()
            
        }
    }
    //MARK: -ヘルパー
    func configureUI(){
        view.backgroundColor = .black
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,
                                                   fullnameTextField,usernameTextField,signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,
                     paddingTop: 32,paddingLeft: 32,paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
    }
    
    func configureNotificationObserver(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

//MARK: -FormViewModel
extension RegistrationController:FormViewModel{
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
    }
}
//MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension RegistrationController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {return}
        profileImage = selectedImage
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.orange.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
}
