//
//  MessageServices.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/06.
//

import Foundation
import Firebase

struct MessageServices {
    static func fetchMessages(otherUser: User, completion: @escaping (([Message]) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var messages: [Message] = []
        let query = Collection_Message.document(uid).collection(otherUser.uid).order(by: "timestamp")
        query.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges.filter({ $0.type == .added
            }) else { return }
            messages.append(contentsOf: documentChanges.map({ Message(dictionary: $0.document.data())
            }))
            completion(messages)
        }
    }
    static func fetchRecentMessages(completion: @escaping ([Message]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Collection_Message.document(uid).collection("recent-message").order(by: "timestamp", descending: true)
        query.addSnapshotListener { snapshot, _ in
            guard let documentChanges = snapshot?.documentChanges else { return }
            let messages = documentChanges.map({Message(dictionary: $0.document.data())})
            completion(messages)
        }
    }
    static func uploadMessage(message: String = "", imageURL: String = "", videoURL: String = "", audioURL: String = "", locationURL: String = "", currentUser: User, otherUser: User, unreadCnt: Int, completion: ((Error?) -> Void)?) {
        let dataFrom: [String: Any] = [
            "text": message,
            "fromID": currentUser.uid,
            "toID": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            "username": otherUser.username,
            "fullname": otherUser.fullname,
            "profileImageURL": otherUser.profileImageURL,
            "new_msg": 0,
            "imageURL": imageURL,
            "videoURL": videoURL,
            "audioURL": audioURL,
            "locationURL": locationURL
        ]
        let dataTo: [String: Any] = [
            "text": message,
            "fromID": currentUser.uid,
            "toID": otherUser.uid,
            "timestamp": Timestamp(date: Date()),
            "username": otherUser.username,
            "fullname": otherUser.fullname,
            "profileImageURL": otherUser.profileImageURL,
            "new_msg": unreadCnt,
            "imageURL": imageURL,
            "videoURL": videoURL,
            "audioURL": audioURL,
            "locationURL": locationURL
        ]
        Collection_Message.document(currentUser.uid).collection(otherUser.uid).addDocument(data: dataFrom) { _ in
            Collection_Message.document(otherUser.uid).collection(currentUser.uid).addDocument(data: dataTo, completion: completion)
            Collection_Message.document(currentUser.uid).collection("recent-message").document(otherUser.uid).setData(dataFrom)
            Collection_Message.document(otherUser.uid).collection("recent-message").document(currentUser.uid).setData(dataTo)
        }
    }
    
    static func fetchSingleRecentMessage(otherUser: User, completion: @escaping(Int) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Collection_Message.document(otherUser.uid).collection("recent-message").document(uid).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else {
                completion(0)
                return
            }
            let message = Message(dictionary: data)
            completion(message.new_msg)
        }
    }
    
    static func markReadAllMessage(otherUser: User) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let updatingData: [String: Any] = [
            "new_msg": 0
        ]
        Collection_Message.document(uid).collection("recent-message").document(otherUser.uid).updateData(updatingData)
    }
    
    static func deleteMessages(otherUser: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Get All conversations
        Collection_Message.document(uid).collection(otherUser).getDocuments { snapshot, _ in
            // Delete All conversations
            snapshot?.documents.forEach({ document in
                let documentID = document.documentID
                Collection_Message.document(uid).collection(otherUser).document(documentID).delete()
            })
            
            // Delete recent messages
            let ref = Collection_Message.document(uid).collection("recent-message").document(otherUser)
            ref.delete(completion: completion)
        }
    }
}

