//
//  ScreenshotGenerator.swift
//  Shortcake
//
//  Created by MacBook Pro M1 on 2023/05/28.
//

import Foundation
import AVKit


class ScreenshotGenerator: ObservableObject {
    @Published var avPlayer: AVPlayer?
    
    init() {
        avPlayer = nil
    }
    
    init(url: URL) {
        avPlayer = AVPlayer(url: url)
    }
}
