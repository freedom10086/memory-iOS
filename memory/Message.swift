//
//  Message.swift
//  memory
//
//  Created by yang on 2018/6/1.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

public struct Message: Codable {
    public var id: Int
    public var imageId: Int
    public var uid: Int
    public var type: Int //0--like 1--comment
    public var content: String?
    public var created: String
    
    public var image: Image?
    public var creater: User?
}
