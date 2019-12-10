# GIFDecompositionAndComposition
iOS中GIF的分解、合成和展示

### 题记
如我们iOS开发者所知，目前iOS还没有支持原生展现GIF图片，因此合成和分解GIF图片对于我们处理各种动画效果有着很高的使用价值。话不多说先看看效果图：

+ 这里提供了3个按钮，本质上是两个方法，分解与合成GIF，因为只要有这两个方法的存在，无论我们拿到的是GIF图还是帧图，我们都能简单地在我们的设备上播放GIF。

![](https://upload-images.jianshu.io/upload_images/3350266-23c21fd452010caf.gif?imageMogr2/auto-orient/strip)
<br>
### 代码

+ 分解GIF
```
/// 把gif动图分解成每一帧图片
    ///
    /// - Parameters:
    ///   - imageType: 分解后的图片格式
    ///   - path: gif路径
    ///   - locatioin: 分解后图片保存路径（如果为空则保存在默认路径）
    ///   - imageName: 分解后图片名称
    
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
```
<br>

+ 合成GIF

```
/// 根据传入图片数组创建gif动图
    ///
    /// - Parameters:
    ///   - images: 源图片数组
    ///   - imageName: 生成gif图片名称
    ///   - imageCuont: 图片总数量

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
```
<br>

+ 播放
+ 这里继承UIImageView定义了一个JJGIFImageView类，增加了一个直接显示GIF图片的方法，只需要把GIF的路径传入，设置GIF时间以及重复次数即可。

```
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

```
<br>

### 最后
[附上简书的传送门](https://www.jianshu.com/p/4771e9ca65af)
