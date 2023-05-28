//
//  CGImage+Extension.swift
//  Shortcake
//
//  Created by MacBook Pro M1 on 2023/05/28.
//

import Cocoa

// MARK: CGImage extension
// https://qiita.com/HaNoHito/items/2fe95aba853f9cedcd3e
extension CGImage {
    var size: CGSize {
        #if swift(>=3.0)
        #else
        let width = CGImageGetWidth(self)
        let height = CGImageGetHeight(self)
        #endif
        return CGSize(width: width, height: height)
    }
    
    var toNSImage: NSImage {
        #if swift(>=3.0)
        return NSImage(cgImage: self, size: size)
        #else
        return NSImage(CGImage: self, size: size)
        #endif
    }
}
