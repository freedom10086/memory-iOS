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
    var creater: User
    var cover: String?
    
    // TODO 稍后补充
}
