//
//  ImageGroup.swift
//  memory
//
//  Created by yang on 2018/5/28.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

public struct ImageGroup: Codable {
    var id: Int
    var galleryId: Int
    var description: String?
    var creater: User?
    var created: String
    var images: [Image]?
}
