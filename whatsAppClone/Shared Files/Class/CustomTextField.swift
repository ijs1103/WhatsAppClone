//
//  CustomTextField.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/06/29.
//

import UIKit

final class CustomTextField: UITextField {
    init(placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        super.init(frame: .zero)
        let spacingView = UIView()
        spacingView.setDimensions(height: 50, width: 12)
        leftView = spacingView
        leftViewMode = .always
        borderStyle = .none
        textColor = .black
        // 키보드 색상
        keyboardAppearance = .light
        // 텍스트 지우기 버튼
        clearButtonMode = .whileEditing
        backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.9568627477, blue: 0.9568627477, alpha: 1)
        setHeight(50)
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecure
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.7)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
