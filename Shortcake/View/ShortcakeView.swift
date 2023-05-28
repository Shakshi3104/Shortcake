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
    @State private var triggers: Bool?
    
    var body: some View {
        VStack {
            if let avPlayer = screenshotGenerator.player {                
                ZStack(alignment: .topTrailing) {
                    // Video player
                    VideoPlayer(player: avPlayer)
                    
                    // Tools
                    VStack {
                        // Screenshot button
                        Button {
                            if triggers == nil {
                                triggers = true
                            } else {
                                triggers?.toggle()
                            }
                        } label: {
                            Image(systemName: "camera")
                        }
                        .buttonStyle(CircleButtonStyle())
                        
                        // open new video button
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(CircleButtonStyle())
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
                screenshotGenerator.player = avPlayer
                
            case .failure(let failure):
                print("🍰 \(failure.localizedDescription)")
            }
        }
        .task(id: triggers) {
            // https://zenn.dev/treastrain/articles/3effccd39f4056
            guard triggers != nil else { return }
            await screenshotGenerator.shot()
        }
    }
}

// MARK: - Preview
struct ShortcakeView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcakeView()
    }
}
