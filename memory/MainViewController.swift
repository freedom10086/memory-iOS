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
        if let openId = Settings.openId {
            //ok login state
            print("登陆状态 openId:\(openId)")
        } else if !isShowLogin{
            //login
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "loginNavViewController")
            self.present(dest!, animated: true, completion: nil)
            isShowLogin = true
        }
    }
}
