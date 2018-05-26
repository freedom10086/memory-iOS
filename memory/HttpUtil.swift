//
//  HttpUtil.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation


//api http 请求类
//自动加入token参数 自动json解析，自动错误处理
class HttpUtil {
    
    //当前正在执行的网络请求数目用于控制小菊花
    private static var  workingSize = 0 {
        didSet {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = workingSize > 0
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

    // get 请求方法
    public static func GET<T>(_ type: T.Type, url: String, params: [String: String]?, callback: @escaping (T? , String) -> Void) where T : Codable {
        var url = getUrl(url: url)
        if let p = encodeParameters(params) {
            if url.contains("?") {
                url = url + "&" + p
            } else {
                url = url + "?" + p
            }
        }
        
        guard let u = URL(string: url) else {
            callback(nil, "错误的请求地址:\(url)")
            return
        }
        
        var request = URLRequest(url: u)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        
        print("start http get url:\(request.url?.absoluteString ?? "")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            HttpUtil.workingSize -= 1
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                callback(nil, error?.localizedDescription ?? "似乎已断开与互联网的连接")
                return
            }
            
            // data != nil && error = nil
            if let res = try? JSONDecoder().decode(ApiResult<T>.self, from: data) {
                if res.status != 200 {
                    callback(nil, res.message)
                    return
                }
                
                if let d = res.data {
                    callback(d, res.message)
                    return
                }
                callback(nil, "未知错误")
            } else {
                // decode error
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    callback(nil, "Http Status: \(httpStatus.statusCode) error: \(String(data: data, encoding: .utf8) ?? "未知错误")")
                } else {
                    callback(nil, "error: \(String(data: data, encoding: .utf8) ?? "未知错误")")
                }
            }
        }
        
        HttpUtil.workingSize += 1
        task.resume()
    }
    
    // post 请求
    public static func POST<T>(_ type: T.Type, url: String, params: [String: Any]?, callback: @escaping (T? , String) -> Void) where T : Codable {
        let url = getUrl(url: url)
        let components = URLComponents(string: url)
        guard let u = components?.url else {
            callback(nil, "请求链接不合法:\(url)");
            return
        }
        
        var ps = params
        if let token = Settings.token {
            if ps != nil {
                ps!["token"] = token
            } else {
                ps = ["token": token]
            }
        }
        
        var request = URLRequest(url: u)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        
        if let p = encodeParameters(ps) {
            request.httpBody = p.data(using: .utf8)
        }
        
        print("start http post url:\(url)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            HttpUtil.workingSize -= 1
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                callback(nil, error?.localizedDescription ?? "似乎已断开与互联网的连接")
                return
            }
            
            // data != nil && error = nil
            if let res = try? JSONDecoder().decode(ApiResult<T>.self, from: data) {
                if res.status != 200 {
                    callback(nil, res.message)
                    return
                }
                
                if let d = res.data {
                    callback(d, res.message)
                    return
                }
                
                callback(nil, "未知错误")
            } else {
                // decode error
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    callback(nil, "Http Status: \(httpStatus.statusCode) error: \(String(data: data, encoding: .utf8) ?? "未知错误")")
                } else {
                    callback(nil, "error: \(String(data: data, encoding: .utf8) ?? "未知错误")")
                }
            }
        }
        
        HttpUtil.workingSize += 1
        task.resume()
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
        
        return Constant.baseUrl + decodeUrl(url: url)
    }
    
    // url编码
    private static func encodeURIComponent(string: String) -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-_.!~*'()")
        
        return string.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
    
}
