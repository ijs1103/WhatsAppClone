//
//  ConversationCell.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import UIKit

final class ConversationCell: UITableViewCell {
    
    var viewModel: MessageViewModel? {
        didSet {
            configure()
        }
    }
    
    static let identifier = "ConversationCell"
    
    private let profileImageView = CustomImageView(image: #imageLiteral(resourceName: "Google_Contacts_logo copy"), width: 60, height: 60, backgroundColor: .lightGray, cornerRadius: 30)
    
    private let fullname = CustomLabel(text: "Fullname")
    private let recentMessage = CustomLabel(text: "recent message", labelColor: .lightGray)
    private let dateLabel = CustomLabel(text: "10/10/2020", labelColor: .lightGray)
    
    private let unreadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .red
        label.setDimensions(height: 30, width: 30)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor)
        let stackView = UIStackView(arrangedSubviews: [fullname, recentMessage])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 15)
        let stackDate = UIStackView(arrangedSubviews: [dateLabel, unreadMsgLabel])
        stackDate.axis = .vertical
        stackDate.spacing = 7
        stackDate.alignment = .trailing
        
        addSubview(stackDate)
        stackDate.centerY(inView: profileImageView, rightAnchor: rightAnchor, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        self.profileImageView.sd_setImage(with: viewModel.profileImageURL)
        self.fullname.text = viewModel.fullname
        self.recentMessage.text = viewModel.messageText
        self.dateLabel.text = viewModel.timestampString
        self.unreadMsgLabel.text = "\(viewModel.unreadCount)"
        self.unreadMsgLabel.isHidden = viewModel.shouldHideUnreadLabel
    }
}
