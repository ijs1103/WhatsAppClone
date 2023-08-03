//
//  UserViewModel.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/05.
//

import Foundation

struct UserViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    var username: String {
        return user.username
    }
    var profileImageView: URL? {
        return URL(string: user.profileImageURL)
    }
    init(user: User) {
        self.user = user
    }
}
