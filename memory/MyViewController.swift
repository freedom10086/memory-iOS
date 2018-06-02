//
//  MyViewController.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

// 我的页面
class MyViewController: UITableViewController {

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var messageDot: UIView!
    
    private var loadedUid = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        messageDot.layer.cornerRadius = messageDot.frame.width / 2
        setupView()
    }
    
    private func setupView() {
        loadedUid = Settings.uid
        usernameLabel.text = Settings.username ?? "Unknown"
        
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.width / 2
        if let avatar = Settings.avatar {
            userAvatarImage.kf.setImage(with: URL(string: avatar), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        }
        
        self.messageDot.isHidden = (MainViewController.unReadMessageCout == 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.messageDot.isHidden = (MainViewController.unReadMessageCout == 0)
        
        if Settings.uid <= 0 {
            //login
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "loginNavViewController")
            self.present(dest!, animated: true, completion: nil)
        } else {
            if (Settings.lastCheckMessageTime?.timeIntervalSince1970 ?? -310) < -300 {
                print("time goes 300s check message")
                MainViewController.checkMessage()
            }
        }
        
        if loadedUid != Settings.uid {
            setupView()
        }
    }
    
    
    @IBAction func updateUserInfoClick(_ sender: Any) {
        let alert = UIAlertController(title: "修改资料", message: "请出入你的新昵称", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (text) in
            text.placeholder = ""
        })
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (ac) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text?.count  ?? 0) > 0 {
                self.updateInfo(name: textField.text!)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateInfo(name: String) {
        Api.updateUsername(name: name) { (count, err) in
            DispatchQueue.main.async {
                if let c = count {
                    print("===\(c)===")
                    self.usernameLabel.text = name
                    Settings.username = name
                } else {
                    self.showAlert(title: "错误", message: err)
                }
            }
        }
    }

}
