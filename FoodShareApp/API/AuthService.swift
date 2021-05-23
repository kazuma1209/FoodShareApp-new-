//
//  AuthService.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/04.
//

import UIKit
import Firebase

struct AuthCredenticals {
    let email:String
    let password:String
    let fullname:String
    let username:String
    let profileImage:UIImage
}

struct AuthService {
    
    //MARK: ログイン
    static func logUserIn(withEmail email:String,password:String,completion:AuthDataResultCallback?){
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    //MARK: サインアップ
    static func registerUser(withCredenticals credenticals:AuthCredenticals,completion:@escaping(Error?)->Void){
        
        //最初にプロフィール画像のアップロード
        ImageUploader.uploadImage(image: credenticals.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credenticals.email, password: credenticals.password) { result, error in
                if let error = error{
                    print("DEBUG: 登録に失敗->\(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else {return}
                
                let data:[String:Any] = ["email":credenticals.email,"fullname":credenticals.fullname,
                                         "profileImageUrl":imageUrl,"uid":uid,"username":credenticals.username]
                
                // データベース：users/uid/ユーザデータ
                COLLECTION_USERS.document(uid).setData(data,completion: completion)
            }
        }
    }
    //MARK: パスワードのリセット
    static func resetPassword(withEmail email:String,completion:SendPasswordResetCallback?){
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
}
