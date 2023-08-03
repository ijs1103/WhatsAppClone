//
//  LoginViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/06/06.
//
import UIKit
import Firebase

final class LoginViewController: UIViewController {
    
    var viewModel = LoginViewModel()
    
    private let welcomeLabel = CustomLabel(text: "HEY, WELCOME", labelFont: .boldSystemFont(ofSize: 20))
    
    private let profileImageView = CustomImageView(image: UIImage(named: "profile"), width: 50, height: 50)

    private let emailTF = CustomTextField(placeholder: "Email", keyboardType: .emailAddress)
    
    private let passwordTF = CustomTextField(placeholder: "Password", isSecure: true)
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleLoginVC), for: .touchUpInside)
        button.blackButton(buttonText: "Login")
        return button
    }()
    
    private lazy var forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forget your password? Get Help Sigining in", for: .normal)
        button.attributedText(firstString: "Forget your password?", secondString: "Get Help Signing in")
        button.setHeight(50)
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Don't Have an account?", secondString: "Sign up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    private let contLabel = CustomLabel(text: "or countinue with Google", labelColor: .lightGray)

    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForTextField()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        [ welcomeLabel, profileImageView, signUpButton, contLabel, googleButton ].forEach {
            view.addSubview($0)
        }
        welcomeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        welcomeLabel.centerX(inView: view)
        profileImageView.anchor(top: welcomeLabel.bottomAnchor, paddingTop: 20)
        profileImageView.centerX(inView: view)
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, loginButton, forgetPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        signUpButton.centerX(inView: view)
        contLabel.centerX(inView: view, topAnchor: forgetPasswordButton.bottomAnchor, paddingTop: 30)
        googleButton.centerX(inView: view, topAnchor: contLabel.bottomAnchor, paddingTop: 12)
    }
    
    private func configureForTextField() {
        emailTF.addTarget(self, action: #selector(handleTextChanged(sender:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextChanged(sender:)), for: .editingChanged)
    }
    
    @objc private func handleLoginVC() {
        guard let email = emailTF.text?.lowercased() else { return }
        guard let password = passwordTF.text else { return }
        
        showLoader(true)
        AuthServices.loginUser(withEmail: email, withPassword: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.showLoader(false)
            print("Login Success")
            self.navToConversationVC()
        }
    }
    @objc private func handleForgetPassword() {
        
    }
    @objc private func handleSignUp() {
        let registerVC = RegisterViewController()
        registerVC.delegate = self
        navigationController?.pushViewController(registerVC, animated: true)
    }
    @objc private func handleGoogleSignIn() {
        showLoader(true)
        setupGoogle()
    }
    @objc private func handleTextChanged(sender: UITextField) {
        sender == emailTF ? (viewModel.email = sender.text) : (viewModel.password = sender.text)
        updateForm()
    }
    private func updateForm() {
        loginButton.isEnabled = viewModel.formIsFailed
        loginButton.backgroundColor = viewModel.backgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
    func navToConversationVC() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        showLoader(true)
        UserServices.fetchUser(uid: uid) { [weak self] user in
            guard let self = self else { return }
            self.showLoader(false)
            let conversationVC = ConversationViewController(user: user)
            let nav = UINavigationController(rootViewController: conversationVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}

extension LoginViewController: RegisterViewControllerDelegate {
    func didSuccessRegister(_ vc: RegisterViewController) {
        vc.navigationController?.popViewController(animated: true)
        navToConversationVC()
    }
}
