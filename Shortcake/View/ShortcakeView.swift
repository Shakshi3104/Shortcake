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
    /// show a screenshot
    @State private var isShowScreenshot = false
    /// drop target
    @State private var isDropTargeted = false
    /// processing screenshot
    @State private var isProcessing = false
    
    
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
                                Task {
                                    isProcessing = true
                                    await screenshotGenerator.shot()
                                    
                                    // animation
                                    withAnimation {
                                        isShowScreenshot = true
                                    }
                                    
                                    try? await Task.sleep(nanoseconds: 1 * 1000 * 1000 * 1000)
                                    
                                    withAnimation {
                                        isShowScreenshot = false
                                    }
                                    isProcessing = false
                                }
                            } label: {
                                Image(systemName: "camera")
                            }
                            .disabled(isProcessing)
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
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.primary,
                            style: StrokeStyle(
                                lineWidth: 0.8,
                                dash: [2, 2, 2, 2]
                            )
                        )
                    
                    VStack {
                        Text("Drop")
                        Text("or")
                        Button {
                            isPresented.toggle()
                        } label: {
                            Text("Open")
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                    }
                }
                .padding()
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
        .onDrop(of: [ .fileURL], isTargeted: $isDropTargeted) { providers in
            guard let provider = providers.first else { return false }
            
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        let avPlayer = AVPlayer(url: url)
                        DispatchQueue.main.async {
                            screenshotGenerator.player = avPlayer
                        }
                    }
                }
            }
            
            return true
        }
        
    }
}

// MARK: - Preview
struct ShortcakeView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcakeView()
    }
}
