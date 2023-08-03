//
//  VideoPlayerViewController.swift
//  whatsAppClone
//
//  Created by 이주상 on 2023/07/18.
//

import UIKit
import AVKit

final class VideoPlayerViewController: AVPlayerViewController {
    private var videoURL: URL
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Player"
        view.backgroundColor = .systemGray6
        player = AVPlayer(url: videoURL)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingToParent {
            try? FileManager.default.removeItem(at: videoURL)
        }
    }
}
