//
//  Constant.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

// 常量类
// Api的请求地址放到这儿
class Constant {
    
    public static let host = "localhost"
    
    public static let baseUrl = "https://localhost"
    
    // 登陆
    public static let loginUrl = "\(baseUrl)/login"
    
    // 相册列表
    public static let galleriesUrl = "\(baseUrl)/galleries/"
    
    //查询某个相册
    public static func galleryUrl(id: Int) -> String {
        return "\(baseUrl)/galleries/\(id)"
    }
}
