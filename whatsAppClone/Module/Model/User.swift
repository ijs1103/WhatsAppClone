//
//  User.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import Foundation

struct User {
    let email: String
    let username: String
    let fullname: String
    let uid: String
    let profileImageURL: String
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
    }
}
