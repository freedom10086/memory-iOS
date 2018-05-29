//
//  Image.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

// 单张图片实体类
public struct Image: Codable {
    var id: Int
    
    var galleryId: Int
    var url: String
    var creater: User
    var description: String?
    var likes: Int
    var comments: Int
    var created: String
}
