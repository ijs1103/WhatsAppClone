//
//  ProfileCell.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/24.
//

import UIKit

final class ProfileCell: UITableViewCell {
    static let identifier = "ProfileCell"
    var viewModel: ProfileViewModel? {
        didSet {
            configure()
        }
    }
    private let titleLabel = CustomLabel(text: "Name", labelColor: .red)
    private let userLabel = CustomLabel(text: "OPERA")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = UIStackView(arrangedSubviews: [titleLabel, userLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.fieldTitle
        userLabel.text = viewModel.optionType
    }
}
