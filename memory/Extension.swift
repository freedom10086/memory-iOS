//
//  Extension.swift
//  memory
//
//  Created by yang on 2018/5/27.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showBackAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "关闭", style: .cancel, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "好", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    

    func showLoadingView(title: String, message: String) {
        let loadingView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating()
        loadingView.view.addSubview(loadingIndicator)
        present(loadingView, animated: true)
    }
}

extension UIImage {
    func scaleToWidth(width: CGFloat) -> UIImage {
        if self.size.width <= width {
            return self
        }
        
        let alpha = false
        let height = self.size.height / (self.size.width / width)
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, alpha, 0.0)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //调整大小
    func scaleToSizeAndWidth(width: CGFloat, maxSize: Int) -> Data? {
        let image = self.scaleToWidth(width: width) //原始缩放过后的image
        print("after scale image width to \(width) size is \(image.size)")
        guard var imageData = UIImageJPEGRepresentation(image, 1.0) else {
            return nil
        }
        
        var sizeKb = (imageData as NSData).length / 1024

        var resizeRate: CGFloat = 0.9
        if (sizeKb / maxSize) > 2 {
            resizeRate = 0.8
        }
        
        while sizeKb > maxSize && resizeRate > 0.1 {
            print("bigger than maxsize scale image resize \(resizeRate)")
            imageData = UIImageJPEGRepresentation(image, resizeRate)!
            sizeKb = (imageData as NSData).length / 1024
            print("after scale size is \(sizeKb)")
            resizeRate -= 0.1
        }
        
        return imageData
    }
}

