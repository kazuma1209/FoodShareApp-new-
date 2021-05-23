//
//  AuthenticationViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/03.
//

import UIKit

protocol FormViewModel {
    func updateForm()
}

protocol AuthenticationViewModel {
    var formIsValid:Bool{get}
    var buttonBackgroundColor:UIColor{get}
    var buttonTitleColor:UIColor{get}
}

struct LoginViewModel:AuthenticationViewModel{
    var email:String?
    var password:String?
    
    var formIsValid:Bool{
        //emailとpasswordがemptyならばtrueを返す
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor:UIColor{
        return formIsValid ? #colorLiteral(red: 1, green: 0.4771001339, blue: 0, alpha: 1) : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor:UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}
struct RegistrationViewModel:AuthenticationViewModel{
    
    var email:String?
    var password:String?
    var fullname:String?
    var username:String?
    
    var formIsValid: Bool{
        return email?.isEmpty == false && password?.isEmpty == false
            && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor{
        return formIsValid ? #colorLiteral(red: 1, green: 0.4771001339, blue: 0, alpha: 1) : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
}

struct ResetPasswordViewModel : AuthenticationViewModel{
    var email:String?
    
    var formIsValid: Bool{
        return email?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor{
        return formIsValid ? #colorLiteral(red: 1, green: 0.4771001339, blue: 0, alpha: 1) : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}

