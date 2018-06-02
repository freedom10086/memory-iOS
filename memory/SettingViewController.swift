//
//  SettingViewController.swift
//  memory
//
//  Created by yang on 2018/5/27.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var avaterImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        avaterImageView.clipsToBounds = true
        avaterImageView.layer.cornerRadius = avaterImageView.frame.width / 2
        if let avatar = Settings.avatar {
            avaterImageView.kf.setImage(with: URL(string: avatar), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        }
        
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    @objc private func logout() {
        Settings.uid = 0
        Settings.accessToken = nil
        Settings.avatar = nil
        Settings.expiresIn = Date()
        Settings.openId = nil
        Settings.token = nil
        MainViewController.unReadMessageCout = 0
        self.showBackAlert(title: "提示", message: "退出登陆成功")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
