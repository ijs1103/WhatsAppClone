//
//  Buttons.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/06/29.
//

import UIKit

extension UIButton {
    func attributedText(firstString: String, secondString: String) {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 16)
        ]
        let attributedTitle = NSMutableAttributedString(string: "\(firstString)", attributes: attributes)
        let secondAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.88), .font: UIFont.systemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: secondString, attributes: secondAttributes))
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func blackButton(buttonText: String) {
        setTitle(buttonText, for: .normal)
        tintColor = .white
        backgroundColor = .black.withAlphaComponent(0.5)
        setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        setHeight(50)
        layer.cornerRadius = 5
        titleLabel?.font = .boldSystemFont(ofSize: 19)
        isEnabled = false
    }
}
