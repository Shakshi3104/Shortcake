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
            
            
            
            if let (image, actualTime) = try? await imageGenerator.image(at: player.currentTime()) {
                print("🍰 Take a screenshot!")
                DispatchQueue.main.async {
                    self.screenshot = image
                }
                
                // Generate filename
                let videoName = url.deletingPathExtension().lastPathComponent
                let seconds = String(format: "%.3f", actualTime.seconds)
                print("🍰 \(videoName) \(seconds)")
                let filename = "\(videoName)-\(seconds)"
                
                guard let downloadDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
                let fileURL = downloadDir.appendingPathComponent(filename, conformingTo: .png)
                print("🍰 \(fileURL)")
                
                // Save png image
                let rep = NSBitmapImageRep(cgImage: image)
                if let data = rep.representation(using: .png, properties: [:]) {
                    do {
                        try data.write(to: fileURL)
                    } catch {
                        print("🍰 \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
