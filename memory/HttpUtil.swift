//
//  HttpUtil.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation
import Alamofire


//api http 请求类
//自动加入token参数 自动json解析，自动错误处理
class HttpUtil {
    
    public static var enableStatusProgress = true
    
    //当前正在执行的网络请求数目用于控制小菊花
    private static var workingSize = 0 {
        didSet {
            if (workingSize == 0 || workingSize == 1) && enableStatusProgress {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = workingSize > 0
                }
            }
        }
    }

    public static func REQUEST<T>(_ type: T.Type, url: String,
                                  method:String = "GET", params: [String: Any]?,
                                  callback: @escaping (T? , String) -> Void) where T : Codable {
        
        var url = getUrl(url: url)
        
        var ps  = params
        if let token = Settings.token {
            if ps != nil {
                ps!["token"] = token
            } else {
                ps = ["token": token]
            }
        }
        
        let p = encodeParameters(ps)
        if let q = p, method == "GET" {
            if url.contains("?") {
                url = url + "&" + q
            } else {
                url = url + "?" + q
            }
        }
        
        let u: URL?
        if method == "GET" {
            u = URL(string: url)
        } else {
            u = URLComponents(string: url)?.url
        }
        
        if u == nil {
            callback(nil, "请求链接不合法:\(url)")
            return
        }
        
        var request = URLRequest(url: u!)
        request.httpMethod = method
        request.timeoutInterval = 8
        
        if let q = p, method != "GET" {
            request.httpBody = q.data(using: .utf8)
        }
        
        print("start http \(method) url:\(url)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            HttpUtil.workingSize -= 1
            handleResponse(type, data: data, response: response, error: error, callback: callback)
        }
        
        HttpUtil.workingSize += 1
        task.resume()
    }
    
    // 上传文件
    // 有bug服务器接收到0字节数据
    public static func UPLOAD2(url: String, data: Data, callback: @escaping (UploadResult? , String) -> Void) {
        let u: String
        if let token = Settings.token {
            if url.contains("?") {
                u = getUrl(url: "\(url)&token=\(token)")
            } else {
                u = getUrl(url: "\(url)?token=\(token)")
            }
        } else {
            u = getUrl(url: url)
        }
        
        var request = URLRequest(url: URL(string: u)!)
        request.httpMethod = "POST"
        request.setValue("uploadimage.jpg", forHTTPHeaderField: "filename")
        
        print("=========")
        print((data as NSData).length)
        let uploadTask = URLSession.shared.uploadTask(with: request, from: data) {
            (data:Data?, response:URLResponse?, error:Error?) -> Void in
            HttpUtil.workingSize -= 1
            handleResponse(UploadResult.self, data: data, response: response, error: error, callback: callback)
        }
        
        HttpUtil.workingSize += 1
        uploadTask.resume()
    }
    
    public static func UPLOAD(url: String, data: Data, callback: @escaping (UploadResult? , String) -> Void) {
        let u: String
        if let token = Settings.token {
            if url.contains("?") {
                u = getUrl(url: "\(url)&token=\(token)")
            } else {
                u = getUrl(url: "\(url)?token=\(token)")
            }
        } else {
            u = getUrl(url: url)
        }
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
        }, to: u,encodingCompletion: { encodingResult in
            switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseData(completionHandler: { (response) in
                            handleResponse(UploadResult.self, data: response.data, response: response.response,
                                           error: response.error, callback: callback)
                        })
                    case .failure(let error):
                        callback(nil, error.localizedDescription)
                }
        })
    }
    
    private static func handleResponse<T>(_ type: T.Type,
                                          data:Data?, response:URLResponse?, error:Error?, callback: @escaping (T? , String) -> Void) where T : Codable {
        if let error = error {
            print("(1) \(error.localizedDescription)")
            callback(nil, error.localizedDescription)
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            callback(nil, "not a HTTPURLResponse")
            return
        }
        
        // check code 200-300
        if let mimeType = response.mimeType,mimeType == "application/json", let d = data {
            do {
                let res = try JSONDecoder().decode(ApiResult<T>.self, from: d)
                if res.status == 200 {
                    print("status = 200")
                    callback(res.data, res.message ?? "success")
                } else {
                    print("status = \(res.status)")
                    callback(nil, res.message ?? "success")
                }
                return
            } catch let err {
                let dataStr = String(data: d, encoding: .utf8)
                print("json parse error \(err.localizedDescription) \(dataStr)")
                callback(nil, err.localizedDescription)
                return
            }
        } else {
            if let d = data, let errstring = String(data: d, encoding: .utf8) {
                callback(nil, errstring)
                return
            } else {
                callback(nil, "empty or unknown response")
            }
        }
    }
    
    public static func encodeUrl(url: Any) -> String? {
        return encodeURIComponent(string: String(describing: url))
        //let escapedString = .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //return escapedString!
    }
    
    public static func decodeUrl(url: String) -> String {
        return url.replacingOccurrences(of: "&amp;", with: "&")
    }
    
    private static func encodeParameters(_ params: [String: Any]?) -> String? {
        if let p = params {
            var pp: String = ""
            p.forEach({ key, value in
                if pp.count > 0 {
                    pp.append("&")
                }
                
                pp.append(key)
                pp.append("=")
                if let v = encodeUrl(url: value) {
                    pp.append(v)
                }
            })
            
            return pp
        } else {
            return nil
        }
    }
    
    private static func encodePostParameters(_ params: [String: Any]?) -> [URLQueryItem]? {
        if let ps = params {
            var items = [URLQueryItem]()
            ps.forEach({ key, value in
                items.append(URLQueryItem(name: key, value: String(describing: value)))
            })
            return items
        } else {
            return nil
        }
    }
    
    private static func getUrl(url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return decodeUrl(url: url)
        }
        
        return Api.baseUrl + decodeUrl(url: url)
    }
    
    // url编码
    private static func encodeURIComponent(string: String) -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-_.!~*'()")
        
        return string.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
}
