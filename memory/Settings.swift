//
//  Settings.swift
//  Ruisi
//
//  Created by yang on 2017/6/24.
//  Copyright © 2017年 yang. All rights reserved.
//

import Foundation

// 首选项管理类
public class Settings {
    private static let key_avater = "key_avater"
    private static let key_uid = "key_uid"
    private static let key_username = "key_username"
    private static let key_open_id = "key_open_id"
    private static let key_sex = "key_sex"
    private static let key_access_token = "key_access_token"
    private static let key_expires_in = "key_expires_in"
    private static let key_token = "key_token"
    
    
    // 用户id
    public static var uid: Int? {
        get {
            let uid = UserDefaults.standard.integer(forKey: key_uid)
            return uid > 0 ? uid : nil
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_uid)
        }
    }

    //用户名
    public static var username: String? {
        get {
            return UserDefaults.standard.string(forKey: key_username)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key_username)
        }
    }
    
    
    //openId
    public static var openId: String? {
        get {
            return UserDefaults.standard.string(forKey: key_open_id)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_open_id)
        }
    }

    //access_token
    public static var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: key_access_token)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key_access_token)
        }
    }
    
    public static var expiresIn: Int {
        get {
            return UserDefaults.standard.integer(forKey: key_expires_in)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_expires_in)
        }
    }
    
    //token
    public static var token: String? {
        get {
            return UserDefaults.standard.string(forKey: key_token)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_token)
        }
    }
}
