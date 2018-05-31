//
//  Comment.swift
//  memory
//
//  Created by yang on 2018/5/28.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

public struct Comment: Codable {
    var id: Int
    var imageId: Int
    var creater: User
    var content: String
    var created: String
}
