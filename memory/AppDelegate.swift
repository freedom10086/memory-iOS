//
//  AppDelegate.swift
//  memory
//
//  Created by yang on 2018/5/25.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TencentSessionDelegate, QQApiInterfaceDelegate {
    var window: UIWindow?
    var tencentAuth: TencentOAuth!
    
    var loginDelegate: ((Bool) -> ())?
    var getUserInfoDelegate: ((APIResponse)->())?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.tencentAuth = TencentOAuth(appId: "1106849099", andDelegate: self)
        
        //状态栏颜色
        UIApplication.shared.statusBarStyle = .lightContent
        
        //设置导航栏颜色
        //let textAttributes = [NSAttributedStringKey.foregroundColor: theme.titleColor]
        //UINavigationBar.appearance().titleTextAttributes = textAttributes //标题颜色
        UINavigationBar.appearance().tintColor = UIColor(red: 51 / CGFloat(255), green: 51 / CGFloat(255), blue: 51 / CGFloat(255), alpha: 1.0) //按钮颜色
        //UINavigationBar.appearance().barTintColor = theme.primaryColor //背景色
        
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
        //memory://invite?invitecode=%s
        //邀请链接
        print("=== open app from \(url) ====")
        if let scheme = url.scheme, scheme == "memory" {
            if let host = url.host,let query = url.query, host == "invite" {
                for kv in query.split(separator: Character("&")) {
                    if kv.split(separator: "=").count == 2 &&
                        kv.split(separator: "=")[0] == "invitecode" &&
                        kv.split(separator: "=")[1].count > 0 {
                    
                        print(kv)
                        
                        print("open from invite link inviteCode is \(kv.split(separator: "=")[1])")
                        MainViewController.inviteCode = String(kv.split(separator: "=")[1])
                        
                        if Settings.accessToken == nil {
                            print("==not login return==")
                        }

                        if let inviteCode = MainViewController.inviteCode {
                            Api.checkInviteCode(inviteCode: inviteCode) { (gallery, err) in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                    if let g = gallery {
                                        let alert = UIAlertController(title: "相册邀请", message: "\(g.creater!.name!) 邀请你加入相册 \(g.name) 是否同意邀请?", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "同意", style: .default, handler: { (ac) in
                                            self.joinGallery(gallery: g, inviteCode: inviteCode)
                                        })
                                        alert.addAction(action)
                                        alert.addAction(UIAlertAction(title: "不同意", style: .cancel, handler: { (ac) in
                                            MainViewController.inviteCode = nil
                                        }))
                                        self.window?.rootViewController?.present(alert, animated: true)
                                    } else {
                                        let alert = UIAlertController(title: "加入邀请失败", message: err, preferredStyle: .alert)
                                        let action = UIAlertAction(title: "好", style: .cancel)
                                        alert.addAction(action)
                                        self.window?.rootViewController?.present(alert, animated: true)
                                    }
                                })
                            }
                        }
                    }
                }
            }
            
            return true
        }
        
        // 分享到qq好友部分
        QQApiInterface.handleOpen(url, delegate: self)
        
        let urlKey: String = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
        if urlKey == "com.tencent.mqq" {
            // QQ 的回调
            return  TencentOAuth.handleOpen(url)
        }
        
        return true
    }
    
    // accept invite join gallery
    public func joinGallery(gallery: Gallery, inviteCode: String) {
        Api.joinGallery(inviteCode: inviteCode) { (gallery, err) in
            MainViewController.inviteCode = nil
            DispatchQueue.main.async {
                if let g = gallery {
                    let alert = UIAlertController(title: "提示", message: "成功加入相册 \(g.name)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                    self.window?.rootViewController?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "加入邀请失败", message: err, preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .cancel)
                    alert.addAction(action)
                    self.window?.rootViewController?.present(alert, animated: true)
                }
            }
        }
    }
    
    func tencentDidLogin() {
        print("tencentDidLogin")
        loginDelegate?(true)
        
        if Settings.username == nil {
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
    
    
    // 以下为分享到qq好友回掉
    func onReq(_ req: QQBaseReq!) {
        print("qq share onReq \(req)")
    }
    
    func onResp(_ resp: QQBaseResp!) {
        print("qq share onResp \(resp)")
    }
    
    func isOnlineResponse(_ response: [AnyHashable : Any]!) {
        print("qq share isOnlineResponse \(response)")
    }

}

