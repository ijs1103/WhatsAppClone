//
//  NewChatViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import UIKit
import Firebase

protocol NewChatViewControllerDelegate: AnyObject {
    func controller(_ vc: NewChatViewController, wantChatWithUser otherUser: User)
}

final class NewChatViewController: UIViewController {
    
    weak var delegate: NewChatViewControllerDelegate?
    
    private let tableView = UITableView()
    private var users: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        fetchUsers()
    }
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.rowHeight = 64
    }
    private func configureUI() {
        view.backgroundColor = .white
        title = "Search"
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view?.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
    }
    private func fetchUsers() {
        showLoader(true)
        UserServices.fetchUsers { [weak self] users in
            guard let self = self else { return }
            self.showLoader(false)
            self.users = users
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let index = self.users.firstIndex(where: {$0.uid == uid}) else { return }
            self.users.remove(at: index)
        }
    }
}

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.viewModel = UserViewModel(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        delegate?.controller(self, wantChatWithUser: user)
    }
}
