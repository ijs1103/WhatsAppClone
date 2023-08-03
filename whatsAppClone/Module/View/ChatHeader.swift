//
//  ChatHeader.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/12.
//

import UIKit

final class ChatHeader: UICollectionReusableView {
    
    static let identifier = "ChatHeader"
    
    var dateValue: String? {
        didSet {
            configure()
        }
    }
    private let dateLabel: CustomLabel = {
        let label = CustomLabel(text: "10/10/2010", labelFont: .boldSystemFont(ofSize: 16), labelColor: .white)
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5)
        label.setDimensions(height: 30, width: 100)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dateLabel)
        dateLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let dateValue = dateValue else { return }
        dateLabel.text = dateValue
    }
}
