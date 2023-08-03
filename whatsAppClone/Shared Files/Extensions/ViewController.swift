//
//  ViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import UIKit
import JGProgressHUD
import SDWebImage

extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)
    
    func showLoader(_ show: Bool) {
        view.endEditing(true)
        if show {
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss()
        }
    }
    
    func showMessage(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
    
    func getImage(withImageURL imageURL: URL, completion: @escaping (UIImage) -> Void) {
        SDWebImageManager.shared().loadImage(with: imageURL, options: .continueInBackground, progress: nil) { [weak self] image, data, error, cashType, finished, url in
            guard let self = self else { return }
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            guard let image = image else { return }
            completion(image)
        }
    }
    
    func getDateString(forDate date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
}
