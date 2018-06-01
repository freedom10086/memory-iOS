//
//  ViewController.swift
//  memory
//
//  Created by yang on 2018/5/25.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

class LoginViewController: UIViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.loginDelegate = { success in
            if success {
                print("qq login success openId:\(app.tencentAuth.getUserOpenID()) access_token: \(app.tencentAuth.accessToken)")
                self.showLoadingView(title: "登陆中", message: "请稍后...")
                Api.login(openId: app.tencentAuth.getUserOpenID(), accessToken: app.tencentAuth.accessToken,
                          callback: { [weak self] (user, err)  in
                            DispatchQueue.main.async {
                                let alertVc: UIAlertController
                                if let u = user {
                                    if u.token != nil {
                                        Settings.token = u.token
                                    }
                                    
                                    Settings.username = u.name
                                    Settings.avatar = u.avatar
                                    Settings.uid = u.id
                                    
                                    self?.updateUserInfo(name: u.name!, avatar: u.avatar)
                                    
                                    Settings.expiresIn = app.tencentAuth.expirationDate
                                    Settings.openId = app.tencentAuth.getUserOpenID()
                                    Settings.accessToken = app.tencentAuth.accessToken
                                    
                                    alertVc = UIAlertController(title: "登陆成功", message: "欢迎👏 \(u.name ?? "")", preferredStyle: .alert)
                                    alertVc.addAction(UIAlertAction(title: "好", style: .cancel) { ac in
                                        self?.presentingViewController?.dismiss(animated: true)
                                    })
                                } else {
                                    alertVc = UIAlertController(title: "错误", message: err, preferredStyle: .alert)
                                    alertVc.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                                }
                                
                                // 取消loading
                                self?.dismiss(animated: true, completion: {
                                    self?.present(alertVc, animated: true)
                                })
                            }
                    
                })
            }
        }
        
        app.getUserInfoDelegate = { response in
            // 获取个人信息
            if response.retCode == 0 {
                print("get user info success")
                if let res = response.jsonResponse {
                    self.updateUserInfo(name: ((res["nickname"] as? String) ?? "unknown"),
                                   avatar: res["figureurl_qq_2"] as? String)
                    
                    if Settings.username == nil, let name = res["nickname"] as? String {
                        Settings.username = name
                    }
                    
                    if Settings.avatar == nil, let avatar = res["figureurl_qq_2"] as? String {
                        Settings.avatar = avatar
                    }
                }
            } else {
                // 获取授权信息异常
                print("get user info error")
                print(response.errorMsg)
            }
        }

    }
    
    private func updateUserInfo(name: String, avatar: String?) {
        usernameLabel.text = name
        if let url = avatar {
            avatarImage.kf.setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        }
    }

    @IBAction func loginClick(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        // 需要获取的用户信息
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        appDel.tencentAuth.authorize(permissions)
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        // self.dismiss(animated: true, completion: nil)
        presentingViewController?.dismiss(animated: true)
    }
}
