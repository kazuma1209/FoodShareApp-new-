//
//  UserCellViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/06.
//

import Foundation

//MARK: UserCellに必要な要素

struct UserCellViewModel {
    private let user : User
    
    var profileImageUrl:URL?{
        return URL(string: user.profileImageUrl)
    }
    
    var username:String{
        return user.username
    }
    
    var fullname:String{
        return user.fullname
    }
    
    init(user:User){
        self.user = user
    }
}

