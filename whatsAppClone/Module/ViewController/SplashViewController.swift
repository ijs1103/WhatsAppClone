//
//  SplashViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import UIKit
import Firebase

final class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser?.uid == nil {
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
//            let nav = UINavigationController(rootViewController: loginVC)
//            nav.modalPresentationStyle = .fullScreen
//            present(loginVC, animated: true)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            showLoader(true)
            UserServices.fetchUser(uid: uid) {[self] user in
                self.showLoader(false)
                let conversationVC = ConversationViewController(user: user)
                navigationController?.pushViewController(conversationVC, animated: true)
//                let nav = UINavigationController(rootViewController: conversationVC)
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: true)
            }
        }
    }
}
