//
//  ChatViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import UIKit
import SDWebImage
import ImageSlideshow
import SwiftAudioPlayer

final class ChatViewController: UICollectionViewController {
    
    private var messages = [[Message]]() {
        didSet {
            self.emptyView.isHidden = !messages.isEmpty
        }
    }
    
    private lazy var customInputView: CustomInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let iv = CustomInputView(frame: frame)
        iv.delegate = self
        return iv
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyLabel = CustomLabel(text: "The conversation is new and encrypted", labelColor: .yellow)
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    private lazy var attachAlert: UIAlertController = {
        let alert = UIAlertController(title: "Attach File", message: "Select the button you want to attach from", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.handleCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.handleGallery()
        }))
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            self.present(self.locationAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }()
    
    private lazy var locationAlert: UIAlertController = {
        let alert = UIAlertController(title: "Share Location", message: "Select the button you want to share location", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Current Location", style: .default, handler: { _ in
            self.handleCurrentLocation()
        }))
        alert.addAction(UIAlertAction(title: "Google Map", style: .default, handler: { _ in
            self.handleGoogleMap()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }()
    
    private var currentUser: User
    private var otherUser: User
    
    init(currentUser: User, otherUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChatHeader.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.markReadAllMessages()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markReadAllMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func configureUI() {
        title = otherUser.fullname
        collectionView.backgroundColor = .white
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.identifier)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        // collectionView의 header를 스크롤시에 고정시키게함
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 70, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
    }
    
    private func fetchMessages() {
        MessageServices.fetchMessages(otherUser: otherUser) { [weak self] messages in
            guard let self = self else { return }
            // 일자별로 메시지를 그룹핑 (하나의 일자 == 하나의 section)
            let groupMessages = Dictionary(grouping: messages) { (element) -> String in
                let dateValue = element.timestamp.dateValue()
                let dateString = self.getDateString(forDate: dateValue)
                return dateString ?? ""
            }
            self.messages.removeAll()
            let sortedKeys = groupMessages.keys.sorted(by: { $0 < $1 })
            sortedKeys.forEach { key in
                let values = groupMessages[key]
                self.messages.append(values ?? [])
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToLastItem()
        }
    }
    private func markReadAllMessages() {
        MessageServices.markReadAllMessage(otherUser: otherUser)
    }
}

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let firstMessage = messages[indexPath.section].first else { return UICollectionReusableView() }
            let dateValue = firstMessage.timestamp.dateValue()
            let dateString = getDateString(forDate: dateValue)
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChatHeader.identifier, for: indexPath) as! ChatHeader
            cell.dateValue = dateString
            return cell
        }
        return UICollectionReusableView()
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.identifier, for: indexPath) as! ChatCell
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.delegate = self
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = ChatCell(frame: frame)
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = cell.systemLayoutSizeFitting(targetSize)
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension ChatViewController: CustomeInputViewDelegate {
    func inputViewForAudio(_ view: CustomInputView, audioURL: URL) {
        showLoader(true)
        FileUploader.uploadAudio(audioURL: audioURL) { audioString in
            MessageServices.fetchSingleRecentMessage(otherUser: self.otherUser) { unreadCnt in
                MessageServices.uploadMessage(audioURL: audioString, currentUser: self.currentUser, otherUser: self.otherUser, unreadCnt: unreadCnt + 1) { error in
                    self.showLoader(false)
                    if let error = error {
                        print("\(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func inputViewForAttach(_ view: CustomInputView) {
        present(attachAlert, animated: true)
    }
    
    func inputView(_ view: CustomInputView, wantUploadMessage message: String) {
        MessageServices.fetchSingleRecentMessage(otherUser: otherUser) { [weak self] unreadCnt in
            guard let self = self else { return }
            MessageServices.uploadMessage(message: message, currentUser: self.currentUser, otherUser: self.otherUser, unreadCnt: unreadCnt + 1) { _ in
                self.collectionView.reloadData()
            }
        }
        view.clearTextView()
    }
    
}

extension ChatViewController {
    @objc func handleCamera() {
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
    
    @objc func handleGallery() {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
    
    @objc func handleCurrentLocation() {
        FLocationManager.shared.start { info in
            guard let lat = info.latitude else { return }
            guard let lng = info.longitude else { return }
            self.uploadLocation(lat: "\(lat)", lng: "\(lng)")
            FLocationManager.shared.stop()
        }
    }
    
    @objc func handleGoogleMap() {
        let chatMapVC = ChatMapViewController()
        chatMapVC.delegate = self
        navigationController?.pushViewController(chatMapVC, animated: true)
    }
    
    func uploadLocation(lat: String, lng: String){
        let locationURL = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)"
        self.showLoader(true)
        MessageServices.fetchSingleRecentMessage(otherUser: otherUser) { unreadCnt in
            MessageServices.uploadMessage(locationURL: locationURL, currentUser: self.currentUser, otherUser: self.otherUser, unreadCnt: unreadCnt + 1) { error in
                self.showLoader(false)
                if let error = error {
                    print("error \(error.localizedDescription)")
                    return
                }
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            guard let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String else { return }
            if mediaType == "public.image" {
                // 업로드할 이미지
                guard let image = info[.editedImage] as? UIImage else { return }
                self.uploadImage(withImage: image)
            } else {
                guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
                self.uploadVideo(withVideoURL: videoURL)
            }
        }
    }
}

//MARK: - Upload Media
extension ChatViewController {
    func uploadImage(withImage image: UIImage) {
        showLoader(true)
        FileUploader.uploadImage(image: image) { imageURL in
            MessageServices.fetchSingleRecentMessage(otherUser: self.otherUser) { unreadMsgCnt in
                MessageServices.uploadMessage(imageURL: imageURL, currentUser: self.currentUser, otherUser: self.otherUser, unreadCnt: unreadMsgCnt + 1) { error in
                    self.showLoader(false)
                    if let error = error {
                        print("error \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func uploadVideo(withVideoURL url: URL) {
        showLoader(true)
        FileUploader.uploadVideo(url: url) { videoURL in
            MessageServices.fetchSingleRecentMessage(otherUser: self.otherUser) { unreadMsgCnt in
                MessageServices.uploadMessage(videoURL: videoURL, currentUser: self.currentUser, otherUser: self.otherUser, unreadCnt: unreadMsgCnt + 1) { error in
                    if let error = error {
                        print("error \(error.localizedDescription)")
                        return
                    }
                }
            }
        } failure: { error in
            print("error \(error.localizedDescription)")
            return
        }

    }
}

extension ChatViewController: ChatMapVCDelegate {
    func didTapLocation(lat: String, lng: String) {
        navigationController?.popViewController(animated: true)
        uploadLocation(lat: lat, lng: lng)
    }
    
    
}

extension ChatViewController: ChatCellDelegate {
    func cell(wantToPlayVideo cell: ChatCell, videoURL: URL?) {
        guard let videoURL = videoURL else { return }
        let videoPlayerVC = VideoPlayerViewController(videoURL: videoURL)
        navigationController?.pushViewController(videoPlayerVC, animated: true)
    }
    func cell(wantToShowImage cell: ChatCell, imageURL: URL?) {
        let slideShow = ImageSlideshow()
        guard let imageURL = imageURL else { return }
        SDWebImageManager.shared().loadImage(with: imageURL, progress: nil) { image,_,_,_,_,_ in
            guard let image = image else { return }
            slideShow.setImageInputs([
                ImageSource(image: image),
                
            ])
            slideShow.delegate = self as? ImageSlideshowDelegate
            let slideVC = slideShow.presentFullScreenController(from: self)
            slideVC.slideshow.activityIndicator = DefaultActivityIndicator()
        }
    }
    func cell(wantToPlayAudio cell: ChatCell, audioURL: URL?, isPlaying: Bool) {
        if isPlaying {
            guard let audioURL = audioURL else { return }
            SAPlayer.shared.startRemoteAudio(withRemoteUrl: audioURL)
            SAPlayer.shared.play()
            let _ = SAPlayer.Updates.PlayingStatus.subscribe { playingStatus in
                print("playingStatus: \(playingStatus)")
                if playingStatus == .ended {
                    cell.resetAudioSettings()
                }
            }
        } else {
            SAPlayer.shared.stopStreamingRemoteAudio()
        }
    }
    func cell(wantToOpenGoogleMap cell: ChatCell, locationURL: URL?) {
        guard let googleURLApp = URL(string: "comgooglemaps://") else  { return }
        guard let locationURL = locationURL else { return }
        // 구글맵 설치 유무 확인
        if UIApplication.shared.canOpenURL(googleURLApp) {
            UIApplication.shared.open(locationURL)
        } else {
            UIApplication.shared.open(locationURL, options: [:])
        }
    }
}
