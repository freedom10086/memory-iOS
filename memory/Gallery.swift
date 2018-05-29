//
//  Gallery.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

// 相册实体类
public struct Gallery: Codable {
    var id: Int
    var name: String
    var description: String
    var type: Int
    
    var creater: User? //创建人
    var cover: String? //封面
    
    var images: Int //图片数
    var users: Int //用户数
    
    var groups: [ImageGroup]?
    var created: String
    var updated: String
}
