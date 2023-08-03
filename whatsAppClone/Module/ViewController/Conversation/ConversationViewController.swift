//
//  ConversationViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/03.
//

import UIKit
import Firebase

final class ConversationViewController: UIViewController {
    
    private var user: User
    private let tableView = UITableView()
    private let unreadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .red
        label.setDimensions(height: 40, width: 40)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private var unreadCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.unreadMsgLabel.isHidden = (self.unreadCount == 0)
            }
        }
    }
    private var conversations: [Message] = [] {
        didSet {
            emptyView.isHidden = !conversations.isEmpty
            tableView.reloadData()
        }
    }
    private var filterConversation: [Message] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var conversationDictionary: [String: Message] = [:]
    var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyLabel = CustomLabel(text: "There are no conversations, Click add to start chatting", labelColor: .yellow)
    
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 40, width: 40)
        button.layer.cornerRadius = 40 / 2
        button.addTarget(self, action: #selector(handleProfileButton), for: .touchUpInside)
        return button
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        fetchConversations()
        configureSearchController()
    }
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.backgroundColor = .white
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        tableView.tableFooterView = UIView() // Empty space
    }
    private func configureUI() {
        title = user.fullname
        view.backgroundColor = .white
        let logoutBarButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let newConversationBarButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewChat))
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.rightBarButtonItem = newConversationBarButton
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
        
        view.addSubview(unreadMsgLabel)
        unreadMsgLabel.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 20, paddingBottom: 20)
        
        view.addSubview(profileButton)
        profileButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 10, paddingRight: 20)
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: profileButton.topAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 25, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateProfile), name: .userProfile, object: nil)
    }
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch {
            print("Sign out Error")
        }
    }
    @objc func handleNewChat() {
        let newChatVC = NewChatViewController()
        newChatVC.delegate = self
        let nav = UINavigationController(rootViewController: newChatVC)
        present(nav, animated: true)
    }
    private func enterToChatRoom(currentUser: User, otherUser: User) {
        let chatVC = ChatViewController(currentUser: currentUser, otherUser: otherUser)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    @objc private func handleProfileButton() {
        let profileVC = ProfileViewController(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func handleUpdateProfile() {
        UserServices.fetchUser(uid: user.uid) { user in
            self.user = user
            self.title = user.fullname
        }
    }
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
    }
    
    private func fetchConversations() {
        MessageServices.fetchRecentMessages { [weak self] conversations in
            guard let self = self else { return }
            conversations.forEach { conversation in
                self.conversationDictionary[conversation.chatPartnerID] = conversation
            }
            self.conversations = Array(self.conversationDictionary.values)
            var unreadCount = 0
            self.conversations.forEach { message in
                unreadCount = self.unreadCount + message.new_msg
            }
            self.unreadMsgLabel.text = "\(unreadCount)"
            // 앱 아이콘에 unreadCount 표시
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterConversation.count : conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        let conversation = inSearchMode ? filterConversation[indexPath.row] : conversations[indexPath.row]
        cell.viewModel = MessageViewModel(message: conversation)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = inSearchMode ? filterConversation[indexPath.row] : conversations[indexPath.row]
        showLoader(true)
        UserServices.fetchUser(uid: conversation.chatPartnerID) { [weak self] otherUser in
            guard let self = self else { return }
            self.showLoader(false)
            self.enterToChatRoom(currentUser: self.user, otherUser: otherUser)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showLoader(true)
            let conversation = inSearchMode ? filterConversation[indexPath.row] : conversations[indexPath.row]
            MessageServices.deleteMessages(otherUser: conversation.toID) {[weak self] error in
                guard let self = self else { return }
                self.showLoader(false)
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if self.inSearchMode {
                    self.filterConversation.remove(at: indexPath.row)
                } else {
                    self.conversations.remove(at: indexPath.row)
                }
                tableView.reloadData()
            }
        }
    }
}

extension ConversationViewController: NewChatViewControllerDelegate {
    func controller(_ vc: NewChatViewController, wantChatWithUser otherUser: User) {
        vc.dismiss(animated: true)
        enterToChatRoom(currentUser: user, otherUser: otherUser)
    }
}

extension ConversationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filterConversation = conversations.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        tableView.reloadData()
    }
}

extension ConversationViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}
