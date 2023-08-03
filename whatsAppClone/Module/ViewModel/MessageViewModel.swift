//
//  MessageViewModel.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/06.
//

import UIKit

struct MessageViewModel {
    let message: Message
    var messageText: String {
        return message.text
    }
    var messageBackgroundColor: UIColor {
        return message.isFromCurrnetUser ? #colorLiteral(red: 0.1963742971, green: 0.8433274627, blue: 0.3759059906, alpha: 1) : #colorLiteral(red: 0.9049968123, green: 0.909968555, blue: 0.914185822, alpha: 1)
    }
    var messageColor: UIColor {
        return message.isFromCurrnetUser ? .white : .black
    }
    var unreadCount: Int {
        return message.new_msg
    }
    var shouldHideUnreadLabel: Bool {
        return message.new_msg == 0
    }
    var fullname: String {
        return message.fullname
    }
    var username: String {
        return message.username
    }
    
    var rightAnchorActive: Bool {
        return message.isFromCurrnetUser
    }
    var leftAnchorActive: Bool {
        return !message.isFromCurrnetUser
    }
    // 자신은 채팅창에 내프로필을 보일필요가 없어서
    var shouldHideProfileImage: Bool {
        return message.isFromCurrnetUser
    }
    var profileImageURL: URL? {
        return URL(string: message.profileImageURL)
    }
    var imageURL: URL? {
        return URL(string: message.imageURL)
    }
    var videoURL: URL? {
        return URL(string: message.videoURL)
    }
    var audioURL: URL? {
        return URL(string: message.audioURL)
    }
    var locationURL: URL? {
        // addingPercentEncoding: 어떤 특정 집합에 있지 않은 문자들을 골라 Percent encoded 문자들로 바꿔주는 메서드
        let encodedURL = message.locationURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: encodedURL ?? "")
    }
    var isImageHide: Bool {
        return message.imageURL == ""
    }
    var isTextHide: Bool {
        return message.imageURL != ""
    }
    var isVideoHide: Bool {
        return message.videoURL == ""
    }
    var isAudioHide: Bool {
        return message.audioURL == ""
    }
    var isLocationHide: Bool {
        return message.locationURL == ""
    }
    var timestampString: String? {
        let date = message.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    init(message: Message) {
        self.message = message
    }
}
