//
//  CustomLabel.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/06/30.
//

import UIKit

final class CustomLabel: UILabel {
    init(text: String, labelFont: UIFont = .systemFont(ofSize: 14), labelColor: UIColor = .black) {
        super.init(frame: .zero)
        self.text = text
        self.font = labelFont
        self.textColor = labelColor
        self.textAlignment = .center
        numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
