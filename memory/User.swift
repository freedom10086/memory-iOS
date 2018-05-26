//
//  User.swift
//  memory
//
//  Created by mac on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

// 用户实体类
// token 字段只有登陆成功后才有值其余都是nil
public struct User: Codable {
    public var id: Int
    public var name: String
    public var avatar: String
    public var gender: String
    public var created: String
    
    public var token: String?
}

