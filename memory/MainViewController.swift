//
//  MainViewController.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {

    var isShowLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}
