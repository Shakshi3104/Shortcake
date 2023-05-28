//
//  ScreenshotGenerator.swift
//  Shortcake
//
//  Created by MacBook Pro M1 on 2023/05/28.
//

import Foundation
import AVKit


// MARK: ScreenshotGenerator
class ScreenshotGenerator: ObservableObject {
    @Published var player: AVPlayer?
    @Published var screenshot: CGImage?
    
    init() {
        player = nil
    }
    
    init(url: URL) {
        player = AVPlayer(url: url)
    }
    
    func shot() async {
        if let player, let url = (player.currentItem?.asset as? AVURLAsset)?.url {
            let asset = AVAsset(url: url)
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.requestedTimeToleranceAfter = CMTime.zero
            imageGenerator.requestedTimeToleranceBefore = CMTime.zero
            
            print("🍰 Take a screenshot!")
            
            if let (image, actualTime) = try? await imageGenerator.image(at: player.currentTime()) {
                DispatchQueue.main.async {
                    self.screenshot = image
                }
            }
        }
    }
}
