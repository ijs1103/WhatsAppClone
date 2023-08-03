//
//  FileUploader.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/06/30.
//

import UIKit
import Firebase
import AVKit

struct FileUploader{
    //MARK: - upload image
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void){
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let uid = Auth.auth().currentUser?.uid ?? "/profileImages/"
        
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/\(uid)/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
                guard let fileURL = url?.absoluteString else {return}
                completion(fileURL)
            }
        }
    }
    
    static func uploadAudio(audioURL: URL, completion: @escaping (String) -> Void) {
        let uid = Auth.auth().currentUser?.uid ?? "/profileImages/"
        
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/\(uid)/\(filename)")
        
        ref.putFile(from: audioURL, metadata: nil) { metadata, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
                guard let fileURL = url?.absoluteString else {return}
                completion(fileURL)
            }
        }
    }
    
    //MARK: - upload video
    static func uploadVideo(url: URL,
                                      success : @escaping (String) -> Void,
                                      failure : @escaping (Error) -> Void) {

        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name

        let dispatchgroup = DispatchGroup()

        dispatchgroup.enter()

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputurl = documentsURL.appendingPathComponent(name)
        var ur = outputurl
        self.convertVideo(toMPEG4FormatForVideo: url as URL, outputURL: outputurl) { (session) in

            ur = session.outputURL!
            dispatchgroup.leave()

        }
        dispatchgroup.wait()

        let data = NSData(contentsOf: ur as URL)

        do {

            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)

        } catch {

            print(error)
        }

        let storageRef = Storage.storage().reference().child("Videos").child(name)
        if let uploadData = data as Data? {
            storageRef.putData(uploadData, metadata: nil
                , completion: { (metadata, error) in
                    if let error = error {
                        failure(error)
                    }else{
                        storageRef.downloadURL { (url, error) in
                            guard let fileURL = url?.absoluteString else {return}
                            success(fileURL)
                        }
                    }
            })
        }
    }
    
    static func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        let asset = AVURLAsset(url: inputURL as URL, options: nil)

        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
}

