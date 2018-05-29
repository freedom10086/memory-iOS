//
//  ApiResult.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

// Api返回结果
struct ApiResult<T>: Codable where T: Codable {
    public var status: Int
    public var message: String?
    public var data: T?
}
