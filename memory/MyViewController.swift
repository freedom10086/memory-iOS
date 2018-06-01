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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageDot.layer.cornerRadius = messageDot.frame.width / 2
        usernameLabel.text = Settings.username ?? "Unknown"
        
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.width / 2
        if let avatar = Settings.avatar {
            userAvatarImage.kf.setImage(with: URL(string: avatar), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.messageDot.isHidden = (MainViewController.unReadMessageCout == 0)
        
        if (Settings.lastCheckMessageTime?.timeIntervalSince1970 ?? -310) < -300 {
            print("time goes 300s check message")
            MainViewController.checkMessage()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
