//
//  ViewController.swift
//  GIFDecompositionAndComposition
//
//  Created by JJ on 2018/9/24.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageV: JJGIFImageView!
    let imageArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    @IBAction func decomposition(_ sender: UIButton) {
        guard let path = Bundle.main.path(forResource: "coke", ofType: "gif") else { return }
//        decompositionImage(.png, path)
        decompositionImage(.jpg, path, "", "coke")
    }
    
    @IBAction func generation(_ sender: UIButton) {
        for i in 0...66 {
            guard let image = UIImage(named: "\(i).png") else { return }
            imageArray.add(image)
        }
        compositionImage(imageArray, "plane", imageArray.count)
    }
    
    @IBAction func display(_ sender: UIButton) {        
        guard let path = Bundle.main.path(forResource: "coke", ofType: "gif") else { return }
        imageV.presentationGIFImage(path: path, duration: 5, repeatCount: 1)
    }
    
}

