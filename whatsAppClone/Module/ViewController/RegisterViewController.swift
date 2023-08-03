//
//  RegisterViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/06/06.
//

import UIKit

protocol RegisterViewControllerDelegate: AnyObject {
    func didSuccessRegister(_ vc: RegisterViewController)
}

final class RegisterViewController: UIViewController {
    weak var delegate: RegisterViewControllerDelegate?
    
    var viewModel = RegisterViewModel()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Already Have an account?", secondString: "Login")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.setDimensions(height: 140, width: 140)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handlePhotoButton), for: .touchUpInside)
        return button
    }()
    
    private let emailTF = CustomTextField(placeholder: "Email", keyboardType: .emailAddress)
    private let passwordTF = CustomTextField(placeholder: "Password", isSecure: true)
    private let fullnameTF = CustomTextField(placeholder: "Fullname")
    private let usernameTF = CustomTextField(placeholder: "Username")
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSignUpVC), for: .touchUpInside)
        button.blackButton(buttonText: "Sign Up")
        return button
    }()
    
    private var profileImage: UIImage?
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailTF, passwordTF, fullnameTF, usernameTF, signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configTextField()
    }
    
    private func configUI() {
        view.backgroundColor = .white
        [alreadyHaveAccountButton, photoButton, stackView].forEach {
            view.addSubview($0)
        }
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        photoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        stackView.anchor(top: photoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 30, paddingRight: 30)
        signUpButton.centerX(inView: view, topAnchor: usernameTF.bottomAnchor, paddingTop: 35)
    }
    
    private func configTextField() {
        emailTF.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
        fullnameTF.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
        usernameTF.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
    }
    
    @objc private func handleAlreadyHaveAccountButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handlePhotoButton() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    @objc private func handleSignUpVC() {
        guard let email = emailTF.text?.lowercased() else { return }
        guard let password = passwordTF.text else { return }
        guard let username = usernameTF.text?.lowercased() else { return }
        guard let fullname = fullnameTF.text else { return }
        guard let profileImage = profileImage else { return }
        let credential = AuthCredential(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage)
        showLoader(true)
        AuthServices.registerUser(credential: credential) {[weak self] error in
            guard let self = self else { return }
            self.showLoader(false)
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.delegate?.didSuccessRegister(self)
        }
    }
    
    @objc private func handleTextField(sender: UITextField) {
        if sender == emailTF {
            viewModel.email = sender.text
        } else if sender == passwordTF {
            viewModel.password = sender.text
        } else if sender == fullnameTF {
            viewModel.fullname = sender.text
        } else {
            viewModel.username = sender.text
        }
        updateForm()
    }
    
    private func updateForm() {
        signUpButton.isEnabled = viewModel.formIsFailed
        signUpButton.backgroundColor = viewModel.backgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        self.profileImage = selectedImage
        photoButton.layer.masksToBounds = true
        photoButton.layer.cornerRadius = photoButton.frame.width / 2
        photoButton.layer.borderColor = UIColor.black.cgColor
        photoButton.layer.borderWidth = 2
        photoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
}
