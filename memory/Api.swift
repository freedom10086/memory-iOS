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
    
    public static let host = "101.132.43.60:8080"
    
    public static let baseUrl = "http://\(host)"
    
    // 登陆
    public static let loginUrl = "\(baseUrl)/login"
    
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
    
    public static func getGalleryPlaceholder(type: Int) -> UIImage {
        if type == 1 {
            return #imageLiteral(resourceName: "jiaren")
        } else if type == 2 {
            return #imageLiteral(resourceName: "qinglv")
        } else if type == 3 {
            return #imageLiteral(resourceName: "tongshi")
        } else if type == 4 {
            return #imageLiteral(resourceName: "pengyou")
        } else {
            return #imageLiteral(resourceName: "qita")
        }
    }
    
    // 设置相册封面
    public static func setGalleryCover(image: UIImageView, url: String?,type: Int) {
        if let url = url {
            image.kf.setImage(with: URL(string: url))
        } else {
            image.image = getGalleryPlaceholder(type: type)
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
    // query = nil 正常模式
    // query != nil 搜索模式
    //page 分页第几页; pageSize 每页大小(默认 defaultPageSize); order 排序
    public static func loadGalleries(page: Int, pageSize: Int, order: Order = .newerFirst, query: String? = nil, callback: @escaping ([Gallery]?, String) -> Void){
        var params = ["page":"\(page)", "size": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        let url: String
        if let q = query {
            params["query"] = q
            url = "/search/galleries/"
        } else {
            url = "/galleries/"
        }
        
        HttpUtil.REQUEST([Gallery].self, url: url, params: params, callback: callback)
    }
    
    // 创建相册
    public static func createGallery(name: String, description: String, type: Int = 0, callback: @escaping ((Gallery?, String))-> Void) {
        let parmas = ["name": name, "description": description, "type": "\(type)"]
        HttpUtil.REQUEST(Gallery.self, url: "/galleries/", method: "POST", params: parmas, callback: callback)
    }
    
    // 查询单个相册信息并返回图片列表的指定页
    public static func loadGallery(id: Int, page: Int, pageSize: Int, order: Order = .newerFirst,
                                   callback: @escaping (Gallery?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)", "order": ((order == .newerFirst) ? "newerFirst" : "newerLast")]
        HttpUtil.REQUEST(Gallery.self, url: "/galleries/\(id)", params: params, callback: callback)
    }
    
    // 查询单个返回图片列表的指定页
    public static func loadGalleryGroups(id: Int, page: Int, pageSize: Int, order: Order = .newerFirst,
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
    public static func loadNewsImages(page: Int, pageSize: Int, minTime: UInt64 = 300, callback: @escaping ([ImageGroup]?, String) -> Void) {
        let params = ["page":"\(page)", "pageSize": "\(pageSize)"]
        let start = DispatchTime.now()
        HttpUtil.REQUEST([ImageGroup].self, url: "/galleries/new-image-groups/", params: params) { groups,err in
            let msTime = (DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) //ms
            if msTime < (minTime * 1000000) {
                let deadline = DispatchTime(uptimeNanoseconds: minTime * 1000000 - msTime + DispatchTime.now().uptimeNanoseconds)
                DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                    callback(groups, err)
                })
            } else {
                DispatchQueue.main.async {
                    callback(groups, err)
                }
            }
            
        }
    }
    
    // 上传图片
    public static func uploadImage(data: Data, callback: @escaping (UploadResult? , String) -> Void) {
        HttpUtil.UPLOAD(url: "/files/", data: data, callback: callback)
    }
    
    // 点赞
    public static func doLike(imageId: Int, callback: @escaping ((Int?, String))-> Void) {
        HttpUtil.REQUEST(Int.self, url: "/likes/\(imageId)", method: "POST", params: nil, callback: callback)
    }
    
    //评论
    public static func comment(imageId: Int, content: String, callback: @escaping((Comment?,String))-> Void) {
        let params = ["content": content]
        HttpUtil.REQUEST(Comment.self, url: "/images/\(imageId)/comments/", method: "POST", params: params, callback: callback)
    }
    
    //拉取评论列表
    public static func getComments(imageId: Int, page: Int, pageSize: Int, callback: @escaping(([Comment]?,String))-> Void) {
        let params = ["page":"\(page)","size":"\(pageSize)"]
        HttpUtil.REQUEST([Comment].self, url: "/images/\(imageId)/comments/", params: params, callback: callback)
    }
    
    // 拉取相册成员列表和生成邀请码
    public static func getGalleryMembers(galleryId: Int, callback: @escaping (GalleryUsersAndCode?,String)-> Void) {
        HttpUtil.REQUEST(GalleryUsersAndCode.self, url: "/galleries/\(galleryId)/members/", params: nil, callback: callback)
    }
    
    // 拉取相册页网格列表
    public static func getGalleryGridList(galleryId: Int,page: Int, pageSize: Int, callback: @escaping ([Image]?,String) -> Void) {
        let params = ["page":"\(page)","size":"\(pageSize)"]
        HttpUtil.REQUEST([Image].self, url: "/galleries/\(galleryId)/images/", params: params, callback: callback)
    }
    
    //拉取评论列表
    public static func getMessages(page: Int, pageSize: Int, callback: @escaping(([Message]?,String))-> Void) {
        let params = ["page":"\(page)","size":"\(pageSize)"]
        HttpUtil.REQUEST([Message].self, url: "/messages/", params: params, callback: callback)
    }

    
    //我的未读消息
    public static func getMessagesCount(startId: Int, callback: @escaping((Int?,String))-> Void) {
        let params = ["startId":"\(startId)"]
        HttpUtil.REQUEST(Int.self, url: "/messages/unread", params: params, callback: callback)
    }
    
    // 验证inviteCode
    public static func checkInviteCode(inviteCode: String, callback: @escaping (Gallery?, String) -> Void) {
        let params = ["invitecode":"\(inviteCode)"]
        HttpUtil.REQUEST(Gallery.self, url: "/invite/check", params: params, callback: callback)
    }
    
    // 正式提交邀请
    public static func joinGallery(inviteCode: String, callback: @escaping (Gallery?, String) -> Void) {
        let params = ["invitecode":"\(inviteCode)"]
        HttpUtil.REQUEST(Gallery.self, url: "/invite/join", method: "POST", params: params, callback: callback)
    }
    
    // TODO
    // 添加更多的API实现
}
