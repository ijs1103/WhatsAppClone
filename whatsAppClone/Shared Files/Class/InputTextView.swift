//
//  InputTextView.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/05.
//

import UIKit

final class InputTextView: UITextView {
    
    let placeHolderLabel = CustomLabel(text: "메시지를 입력하세요.", labelColor: .lightGray)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = #colorLiteral(red: 0.9568626285, green: 0.9568627477, blue: 0.9611683488, alpha: 1)
        layer.cornerRadius = 20
        isScrollEnabled = false
        font = .systemFont(ofSize: 16)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.centerY(inView: self, leftAnchor: leftAnchor, rightAnchor: rightAnchor, paddingLeft: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        paddingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTextDidChange() {
        placeHolderLabel.isHidden = !text.isEmpty
    }
}

extension UITextView {
    func paddingView() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }
}
