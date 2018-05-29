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
        guard var imageData = UIImageJPEGRepresentation(image, 1.0) else {
            return nil
        }
        
        var sizeKb = (imageData as NSData).length / 1024
        var resizeRate: CGFloat = 0.9
        
        while sizeKb > maxSize && resizeRate > 0.1 {
            imageData = UIImageJPEGRepresentation(image, resizeRate)!
            sizeKb = (imageData as NSData).length / 1024
            resizeRate -= 0.1
        }
        
        return imageData
    }
}

