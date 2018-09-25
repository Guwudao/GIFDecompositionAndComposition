//
//  JJGIFImageView.swift
//  GIFDecompositionAndComposition
//
//  Created by Jackie on 2018/9/25.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit

class JJGIFImageView: UIImageView {
    
    var images: [UIImage] = []
    
    /// GIF图片展示
    ///
    /// - Parameters:
    ///   - path: GIF所在路径
    ///   - duration: 持续时间
    ///   - repeatCount: 重复次数
    public func presentationGIFImage(path: String, duration: TimeInterval, repeatCount: Int) {
        decompositionImage(path)
        displayGIF(duration, repeatCount)
    }
    
    private func decompositionImage(_ path: String) {
        //把图片转成data
        let gifDate = try! Data(contentsOf: URL(fileURLWithPath: path))
        guard let gifSource = CGImageSourceCreateWithData(gifDate as CFData, nil) else { return }
        //计算图片张数
        let count = CGImageSourceGetCount(gifSource)
        //把每一帧图片拼接到数组
        for i in 0...count-1 {
            guard let imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, nil) else { return }
            let image = UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up)
            images.append(image)
        }
    }
    
    private func displayGIF(_ duration: TimeInterval, _ repeatCount: Int) {
        self.animationImages = images
        self.animationDuration = duration
        self.animationRepeatCount = repeatCount
        self.startAnimating()
    }
    
}

