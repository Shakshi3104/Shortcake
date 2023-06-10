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
    
    /// show file importer
    @State private var isPresented = false
    /// take a screenshot
    @State private var triggers: Bool?
    /// show a screenshot
    @State private var isShowScreenshot = false
    
    
    var body: some View {
        VStack {
            if let avPlayer = screenshotGenerator.player {
                ZStack(alignment: .bottomTrailing) {
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
                            .keyboardShortcut("0", modifiers: [.command, .shift])
                            
                            // open new video button
                            Button {
                                isPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(CircleButtonStyle())
                            .keyboardShortcut("n", modifiers: [.command])
                        }
                        .padding()
                    }
                    
                    // Taken screenshot
                    if let cgImage = screenshotGenerator.screenshot {
                        if isShowScreenshot {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 170, height: 100)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Image(nsImage: cgImage.toNSImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 160, height: 90)
                            }
                            .padding(5)
                            .transition(.asymmetric(insertion: .identity, removal: .slide).combined(with: .opacity))
                        }
                    }
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
            
            // animation
            withAnimation {
                isShowScreenshot = true
            }
            
            try! await Task.sleep(nanoseconds: 2 * 1000 * 1000 * 1000)
            
            withAnimation {
                isShowScreenshot = false
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
