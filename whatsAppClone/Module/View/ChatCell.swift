//
//  ChatCell.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/04.
//

import UIKit

protocol ChatCellDelegate: AnyObject {
    func cell(wantToPlayVideo cell: ChatCell, videoURL: URL?)
    func cell(wantToShowImage cell: ChatCell, imageURL: URL?)
    func cell(wantToPlayAudio cell: ChatCell, audioURL: URL?, isPlaying: Bool)
    func cell(wantToOpenGoogleMap cell: ChatCell, locationURL: URL?)
}

final class ChatCell: UICollectionViewCell {
    
    weak var delegate: ChatCellDelegate?
    
    var viewModel: MessageViewModel? {
        didSet {
            configure()
        }
    }
    
    static let identifier = "ChatCell"
    
    private let profileImageView = CustomImageView(width: 30, height: 30, backgroundColor: .lightGray, cornerRadius: 15)
    private let dateLabel = CustomLabel(text: "10/10/2020", labelFont: .systemFont(ofSize: 12), labelColor: .lightGray)
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9245408177, green: 0.9278380275, blue: 0.9309870005, alpha: 1)
        return view
    }()
    
    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    var dateRightAnchor: NSLayoutConstraint!
    var dateLeftAnchor: NSLayoutConstraint!
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.text = "Sample Data"
        return textView
    }()
    
    private lazy var postImage: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostImage))
        let iv = CustomImageView()
        iv.isHidden = true
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var postVideo: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("비디오 재생", for: .normal)
        button.addTarget(self, action: #selector(handleVideoButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postAudio: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("오디오 재생", for: .normal)
        button.addTarget(self, action: #selector(handleAudioButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postLocation: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("Google Map", for: .normal)
        button.addTarget(self, action: #selector(handleLocationButton), for: .touchUpInside)
        return button
    }()
    
    var isVoicePlaying: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 10)
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        addSubview(dateLabel)
        dateLeftAnchor = dateLabel.leftAnchor.constraint(equalTo: bubbleContainer.rightAnchor, constant: 12)
        dateLeftAnchor.isActive = false
        
        dateRightAnchor = dateLabel.rightAnchor.constraint(equalTo: bubbleContainer.leftAnchor, constant: -12)
        dateRightAnchor.isActive = false
        
        dateLabel.anchor(bottom: bottomAnchor)
        
        addSubview(postImage)
        postImage.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postVideo)
        postVideo.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postAudio)
        postAudio.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postLocation)
        postLocation.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        guard let viewModel = viewModel else { return }
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.text = viewModel.messageText
        textView.textColor = viewModel.messageColor
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        dateRightAnchor.isActive = viewModel.rightAnchorActive
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        dateLeftAnchor.isActive = viewModel.leftAnchorActive
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        
        guard let timestampString = viewModel.timestampString else { return }
        dateLabel.text = timestampString
        
        postImage.sd_setImage(with: viewModel.imageURL)
        textView.isHidden = viewModel.isTextHide
        postImage.isHidden = viewModel.isImageHide
        postVideo.isHidden = viewModel.isVideoHide
        postAudio.isHidden = viewModel.isAudioHide
        postLocation.isHidden = viewModel.isLocationHide
        
        if !viewModel.isImageHide {
            postImage.setHeight(200)
        }
    }
    
    @objc private func handleVideoButton() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantToPlayVideo: self, videoURL: viewModel.videoURL)
    }
    
    @objc private func handlePostImage() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantToShowImage: self, imageURL: viewModel.imageURL)
    }
    
    @objc private func handleAudioButton() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantToPlayAudio: self, audioURL: viewModel.audioURL, isPlaying: isVoicePlaying)
        isVoicePlaying.toggle()
        let title = isVoicePlaying ? "오디오 재생" : "오디오 정지"
        let imageName = isVoicePlaying ? "play.fill" : "stop.fill"
        postAudio.setTitle(title, for: .normal)
        postAudio.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func handleLocationButton() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantToOpenGoogleMap: self, locationURL: viewModel.locationURL)
    }
    
    func resetAudioSettings() {
        postAudio.setTitle("오디오 재생", for: .normal)
        postAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
        isVoicePlaying = true
    }
}
