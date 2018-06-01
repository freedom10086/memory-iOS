//
//  MainViewController.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {

    public static var unReadMessageCout = 0
    
    var isShowLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.checkMessage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let accessToken = Settings.accessToken {
            print("认证有效 过期:\(Settings.expiresIn)")
        } else if !isShowLogin {
            print("认证无效 过期:\(Settings.expiresIn)")
            //login
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "loginNavViewController")
            self.present(dest!, animated: true, completion: nil)
            isShowLogin = true
        }
    }
    
    public static func checkMessage() {
        if Settings.accessToken != nil, Settings.uid > 0 {
            print("start load message count last check \(Settings.lastCheckMessageTime?.timeIntervalSinceNow ?? 0)")
            Settings.lastCheckMessageTime = Date()
            Api.getMessagesCount(startId: Settings.messageStartId) { (count, err) in
                if let c = count {
                    MainViewController.unReadMessageCout = c
                    print("have unread message count \(c)")
                } else {
                    print("error get message count")
                }
            }
        }
    }
}
