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
    private static let key_user_id = "key_user_id"
    private static let key_user_name = "key_user_name"
    private static let key_user_avatar = "key_user_avatar"
    
    private static let key_open_id = "key_open_id"
    private static let key_access_token = "key_access_token"
    private static let key_expires_in = "key_expires_in"
    private static let key_token = "key_token"
    
    //user
    public static var user: User? {
        get {
            let name = Settings.username
            let avatar = Settings.avatar
            let uid = Settings.uid
            
            if uid == nil {
                return nil
            } else {
                return User(id: uid!, name: name, avatar: avatar)
            }
        }
    }
    
    //uid
    public static var uid: Int? {
        get {
            return UserDefaults.standard.integer(forKey: key_user_id)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_user_id)
        }
    }
    
    //username
    public static var username: String? {
        get {
            return UserDefaults.standard.string(forKey: key_user_name)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_user_name)
        }
    }
    
    //useravatar
    public static var avatar: String? {
        get {
            return UserDefaults.standard.string(forKey: key_user_avatar)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key_user_avatar)
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
            if let expiresIn =  Settings.expiresIn, (expiresIn.timeIntervalSince1970 - Date().timeIntervalSince1970 - 60) > 0 {
                return UserDefaults.standard.string(forKey: key_access_token)
            }
            
            return nil
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key_access_token)
        }
    }
    
    public static var expiresIn: Date? {
        get {
            return (UserDefaults.standard.value(forKey: key_expires_in)) as? Date
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
