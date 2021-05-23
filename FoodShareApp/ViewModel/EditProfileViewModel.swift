//
//  EditProfileViewModel.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/18.
//
import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    
    var description: String {
        switch self {
        case .username: return "ユーザーネーム"
        case .fullname: return "名前"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullname: return user.fullname
        }
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
