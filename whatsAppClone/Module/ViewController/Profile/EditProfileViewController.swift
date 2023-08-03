//
//  EditProfileViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/24.
//

import UIKit

final class EditProfileViewController: UIViewController {
    private let user: User
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSubmitProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileImageView: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        let imageView = CustomImageView(width: 125, height: 125, backgroundColor: .lightGray, cornerRadius: 125 / 2)
        imageView.addGestureRecognizer(tap)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let fullnameLabel = CustomLabel(text: "Fullname", labelColor: .red)
    private let fullnameText = CustomTextField(placeholder: "fullname")
    private let usernameLabel = CustomLabel(text: "Username", labelColor: .red)
    private let usernameText = CustomTextField(placeholder: "username")
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    var selectImage: UIImage?
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProfileData()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        title = "Edit Profile"
        
        view.addSubview(editButton)
        editButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingRight: 12)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: editButton.bottomAnchor, paddingTop: 10)
        profileImageView.centerX(inView: view)
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, fullnameText, usernameLabel, usernameText])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        fullnameText.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        usernameText.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
    }
    
    private func configureProfileData() {
        fullnameText.text = user.fullname
        usernameText.text = user.username
        
        profileImageView.sd_setImage(with: URL(string: user.profileImageURL))
    }
    
    @objc private func handleSubmitProfile() {
        guard let fullname = fullnameText.text else { return }
        guard let username = usernameText.text else { return }
        showLoader(true)
        if selectImage == nil {
            // 이미지 없이 데이터 업데이트
            let params = [ "fullname": fullname, "username": username ]
            updateUser(params: params)
        } else {
            guard let selectImage = selectImage else { return }
            FileUploader.uploadImage(image: selectImage) { imageURL in
                let params = [ "fullname": fullname, "username": username, "profileImageURL": imageURL]
                self.updateUser(params: params)
            }
        }
    }
    
    @objc private func handleImageTap() {
        present(imagePicker, animated: true)
    }
    
    private func updateUser(params: [String: Any]){
        UserServices.setNewUserData(data: params) { _ in
            self.showLoader(false)
            NotificationCenter.default.post(name: .userProfile, object: nil)
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectImage = image
        self.profileImageView.image = image
        
        dismiss(animated: true)
    }
}
