//
//  Api.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

// api工具类
// 要添加Api支持添加新的函数在Constant.swift中添加url
// callback的第一个返回类型为此Api返回的data的类型，如果类型没有请在model包里面新建，字段名称要和json名称对应
// 第一个参数为类型.self 如 User.self [User].self 分别表示单个用户 和 用户列表
public class Api {
    
    public static let defaultPageSize = 30
    
    public enum Order {
        case newerFirst //新的在前
        case newerLast //旧的在前
    }

    // 登陆
    public static func login(openId: String, accessToken: String?, callback: @escaping (User?, String) -> Void) {
        var params = ["openid":openId]
        if let token = accessToken {
            params["access_token"] = token
        }
        
        // 调用http的post请求
        HttpUtil.POST(User.self, url: Constant.loginUrl, params: params, callback: callback)
    }
    
    // 获得我的相册列表
    //page 分页第几页; pageSize 每页大小(默认 defaultPageSize); order 排序
    public static func loadGalleries(page: Int, pageSize: Int = defaultPageSize, order: Order = .newerFirst,
                                     callback: @escaping ([Gallery]?, String) -> Void){
        
        let params = ["page":"\(page)", "size": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        HttpUtil.GET([Gallery].self, url: Constant.galleriesUrl, params: params, callback: callback)
    }
    
    // 查询单个相册信息并返回图片列表的指定页
    public static func loadGallery(id: Int, page: Int, pageSize: Int = defaultPageSize, order: Order = .newerFirst,
                                   callback: @escaping (Gallery?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        HttpUtil.GET(Gallery.self, url: Constant.galleryUrl(id: id), params: params, callback: callback)
    }
    
    // 最新页面
    public static func loadNewsImages(page: Int, pageSize: Int = defaultPageSize,callback: @escaping ([ImageGroup]?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)"]
        HttpUtil.GET([ImageGroup].self, url: Constant.newImagesUrl, params: params, callback: callback)
    }
    
    // TODO
    // 添加更多的API实现
}
