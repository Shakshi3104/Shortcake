//
//  ShortcakeView.swift
//  Shortcake
//
//  Created by MacBook Pro M1 on 2023/05/27.
//

import SwiftUI
import AVKit

// MARK: - CircleButtonStyle
struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color(nsColor: .shadowColor).opacity(0.6))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - ShortcakeView
struct ShortcakeView: View {
    @StateObject var screenshotGenerator = ScreenshotGenerator()
    
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            if let avPlayer = screenshotGenerator.avPlayer {
                ZStack(alignment: .topTrailing) {
                    // Video player
                    VideoPlayer(player: avPlayer)
                    
                    Button {
                        //
                    } label: {
                        Image(systemName: "camera")
                    }
                    .padding()
                }
            } else {
                Button {
                    isPresented.toggle()
                } label: {
                    Text("Open")
                }
            }
        }
        .fileImporter(isPresented: $isPresented, allowedContentTypes: [.movie, .quickTimeMovie, .mpeg4Movie]) { result in
            switch result {
            case .success(let url):
                let avPlayer = AVPlayer(url: url)
                screenshotGenerator.avPlayer = avPlayer
                
            case .failure(let failure):
                print("🍰 \(failure.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview
struct ShortcakeView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcakeView()
    }
}
