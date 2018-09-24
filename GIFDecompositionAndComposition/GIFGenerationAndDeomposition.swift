//
//  GIFDecompositionAndComposition.swift
//  fakeGPS
//
//  Created by JJ on 2018/9/24.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit
import MobileCoreServices

enum imageType {
    case png
    case jpg
}

extension UIViewController {
    
    func compositionImage(_ images: NSMutableArray, _ imageName: String, _ imageCuont: Int) {
        
        //在Document目录下创建gif文件
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let gifPath = docs[0] + "/\(imageName)" + ".gif"
        guard let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, .cfurlposixPathStyle, false), let destinaiton = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imageCuont, nil) else { return }
        
        //设置每帧图片播放时间
        let cgimageDic = [kCGImagePropertyGIFDelayTime as String: 0.1]
        let gifDestinaitonDic = [kCGImagePropertyGIFDictionary as String: cgimageDic]
        
        //添加gif图像的每一帧元素
        for cgimage in images {
            CGImageDestinationAddImage(destinaiton, (cgimage as AnyObject).cgImage!!, gifDestinaitonDic as CFDictionary)
        }
        
        // 设置gif的彩色空间格式、颜色深度、执行次数
        let gifPropertyDic = NSMutableDictionary()
        gifPropertyDic.setValue(kCGImagePropertyColorModelRGB, forKey: kCGImagePropertyColorModel as String)
        gifPropertyDic.setValue(16, forKey: kCGImagePropertyDepth as String)
        gifPropertyDic.setValue(1, forKey: kCGImagePropertyGIFLoopCount as String)
        
        //设置gif属性
        let gifDicDest = [kCGImagePropertyGIFDictionary as String: gifPropertyDic]
        CGImageDestinationSetProperties(destinaiton, gifDicDest as CFDictionary)
        
        //生成gif
        CGImageDestinationFinalize(destinaiton)
        
        print(gifPath)
    }
    
    func decompositionImage( _ imageType: imageType, _ path: String, _ locatioin: String = "", _ imageName: String = "") {
        
        //把图片转成data
        let gifDate = try! Data(contentsOf: URL(fileURLWithPath: path))
        guard let gifSource = CGImageSourceCreateWithData(gifDate as CFData, nil) else { return }
        //计算图片张数
        let count = CGImageSourceGetCount(gifSource)
        
        var dosc: [String] = []
        var directory = ""
        
        //判断是否传入路径，如果没有则使用默认路径
        if locatioin.isEmpty {
            dosc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            directory = dosc[0] + "/"
        }else{
            let index = locatioin.index(locatioin.endIndex, offsetBy: -1)
            if locatioin.substring(from: index) != "/" {
                directory = locatioin + "/"
            }else{
                directory = locatioin
            }
        }
        
        var imagePath = ""
        //逐一取出
        for i in 0...count-1 {
            guard let imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, nil) else { return }
            let image = UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up)
            
            //根据选择不同格式生成对应图片已经路径
            switch imageType {
            case .jpg:
                guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
                if imageName.isEmpty {
                    imagePath = directory + "\(i)" + ".jpg"
                }else {
                    imagePath = directory + "\(imageName)" + "\(i)" + ".jpg"
                }
                try? imageData.write(to: URL.init(fileURLWithPath: imagePath), options: .atomic)
            case .png:
                guard let imageData = UIImagePNGRepresentation(image) else { return }
                if imageName.isEmpty {
                    imagePath = directory + "\(i)" + ".png"
                }else {
                    imagePath = directory + "\(imageName)" + "\(i)" + ".png"
                }
                
                //生成图片
                try? imageData.write(to: URL.init(fileURLWithPath: imagePath), options: .atomic)
            }
            
            print(imagePath)
        }
    }
    
}

