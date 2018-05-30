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
    
    public static let host = "127.0.0.1:8080"
    
    public static let baseUrl = "http://\(host)"
    
    // 登陆
    public static let loginUrl = "\(baseUrl)/login"
    
    // 相册列表
    public static let galleriesUrl = "\(baseUrl)/galleries/"

    
    public static var newImagesUrl = "\(baseUrl)/galleries/new-image-groups/"
    
    public static var uploadImageUrl = "\(baseUrl)/files/"
    
    public static var uploadRawImageUrl = "\(baseUrl)/files/raw/"
    
    public static let defaultPageSize = 30
    
    public enum Order {
        case newerFirst //新的在前
        case newerLast //旧的在前
    }
    
    public static func getGalleryType(type: Int) -> String? {
        if type == 1 {
            return "家人"
        } else if type == 2 {
            return "情侣"
        } else if type == 3 {
            return "同事"
        } else if type == 4 {
            return "朋友"
        } else {
            return nil
        }
    }
    
    // 设置相册封面
    public static func setGalleryCover(image: UIImageView, gallery: Gallery?) {
        if let g = gallery {
            if let cover = g.cover {
                image.kf.setImage(with: URL(string: cover), placeholder: #imageLiteral(resourceName: "image_placeholder"))
            } else {
                
            }
        } else {
            image.image = #imageLiteral(resourceName: "image_placeholder")
        }
    }

    // 登陆
    public static func login(openId: String, accessToken: String?, callback: @escaping (User?, String) -> Void) {
        var params = ["openid":openId]
        if let token = accessToken {
            params["access_token"] = token
        }
        
        // 调用http的post请求
        HttpUtil.REQUEST(User.self, url: loginUrl, method:"POST",
                         params: params, callback: callback)
    }
    
    // 获得我的相册列表
    //page 分页第几页; pageSize 每页大小(默认 defaultPageSize); order 排序
    public static func loadGalleries(page: Int, pageSize: Int = defaultPageSize, order: Order = .newerFirst,
                                     callback: @escaping ([Gallery]?, String) -> Void){
        
        let params = ["page":"\(page)", "size": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        HttpUtil.REQUEST([Gallery].self, url: galleriesUrl, params: params, callback: callback)
    }
    
    // 创建相册
    public static func createGallery(name: String, description: String, type: Int = 0, callback: @escaping ((Gallery?, String))-> Void) {
        let parmas = ["name": name, "description": description, "type": "\(type)"]
        HttpUtil.REQUEST(Gallery.self, url: "/galleries/", method: "POST", params: parmas, callback: callback)
    }
    
    // 查询单个相册信息并返回图片列表的指定页
    public static func loadGallery(id: Int, page: Int, pageSize: Int = defaultPageSize, order: Order = .newerFirst,
                                   callback: @escaping (Gallery?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        HttpUtil.REQUEST(Gallery.self, url: "/galleries/\(id)", params: params, callback: callback)
    }
    
    // 查询单个返回图片列表的指定页
    public static func loadGalleryGroups(id: Int, page: Int, pageSize: Int = defaultPageSize, order: Order = .newerFirst,
                                   callback: @escaping ([ImageGroup]?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        HttpUtil.REQUEST([ImageGroup].self, url: "/galleries/\(id)/image-groups/", params: params, callback: callback)
    }
    
    // 添加照片到相册
    public static func addImageToGallery(galleryId: Int,images: String, description: String, callback: @escaping ((Int?, String))-> Void) {
        let params = ["images":images, "description": description]
        HttpUtil.REQUEST(Int.self, url: "/galleries/\(galleryId)/images/", method: "POST", params: params, callback: callback)
    }
    
    // 最新页面
    public static func loadNewsImages(page: Int, pageSize: Int = defaultPageSize,callback: @escaping ([ImageGroup]?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)"]
        HttpUtil.REQUEST([ImageGroup].self, url: newImagesUrl, params: params, callback: callback)
    }
    
    // 上传图片
    public static func uploadImage(data: Data, callback: @escaping (UploadResult? , String) -> Void) {
        HttpUtil.UPLOAD(url: uploadRawImageUrl, data: data, callback: callback)
    }
    
    // 点赞
    public static func doLike(imageId: Int, callback: @escaping ((Int?, String))-> Void) {
        HttpUtil.REQUEST(Int.self, url: "/likes/\(imageId)", method: "POST", params: nil, callback: callback)
    }
    
    // TODO
    // 添加更多的API实现
}
