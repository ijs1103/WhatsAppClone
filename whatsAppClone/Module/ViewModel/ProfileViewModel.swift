//
//  ProfileViewModel.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/24.
//

import Foundation

enum ProfileField: Int, CaseIterable {
    case fullname, username, email
    var description: String {
        switch self {
        case .fullname:
            return "Fullname"
        case .username:
            return "Username"
        case .email:
            return "Email Address"
        }
    }
}

struct ProfileViewModel {
    let user: User
    let field: ProfileField
    var fieldTitle: String {
        return field.description
    }
    
    var optionType: String? {
        switch field {
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        case .email:
            return user.email
        }
    }
    
    init(user: User, field: ProfileField) {
        self.user = user
        self.field = field
    }
}
