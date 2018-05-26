//
//  AppDelegate.swift
//  memory
//
//  Created by yang on 2018/5/25.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TencentSessionDelegate {

    var window: UIWindow?
    var tencentAuth: TencentOAuth!
    
    var loginDelegate: ((Bool) -> ())?
    var getUserInfoDelegate: ((APIResponse)->())?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.tencentAuth = TencentOAuth(appId: "1106849099", andDelegate: self)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //memory://invite?name=test&password=666
        //邀请链接
        print("open app from \(url)")
        if let scheme = url.scheme, scheme == "memory" {
            if let host = url.host,let query = url.query, host == "invite" {
                for kv in query.split(separator: Character("&")) {
                    print(kv.split(separator: "=")[0])
                    print(kv.split(separator: "=")[1])
                }
            }
            
            return true
        }
        
        let urlKey: String = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
        if urlKey == "com.tencent.mqq" {
            // QQ 的回调
            return  TencentOAuth.handleOpen(url)
        }
        
        return true
    }
    
    func tencentDidLogin() {
        print("tencentDidLogin")
        loginDelegate?(true)
        
        if Settings.user == nil {
            // 登录成功后要调用一下这个方法, 才能获取到个人信息
            self.tencentAuth.getUserInfo()
        }
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        print("tencentDidNotLogin")
        loginDelegate?(false)
    }
    
    func tencentDidNotNetWork() {
        print("tencentDidNotNetWork")
        loginDelegate?(false)
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        getUserInfoDelegate?(response)
    }

}

