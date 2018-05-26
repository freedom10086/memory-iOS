//
//  ViewController.swift
//  memory
//
//  Created by yang on 2018/5/25.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.loginDelegate = { success in
            if success {
                let parameters: Parameters = ["openid": app.tencentAuth.getUserOpenID(),
                                              "access_token": app.tencentAuth.accessToken];
                Alamofire.request("https://www.baidu.com", method: .post, parameters: parameters).responseJSON { response in
                    if (response.result.isSuccess) {
                        let value = response.result.value;
                        let json = JSON(value as Any)
                        let name = json["data"]["name"]
                        let gender = json["data"]["gender"]
                        let created = json["data"]["created"]
                        let token = json["data"]["token"]
                        
                        
                    } else {
                        
                    }
                }
            }
        }
        
        app.getUserInfoDelegate = { response in
            // 获取个人信息
            if response.retCode == 0 {
                print("get user info success")
                if let res = response.jsonResponse {
                    if let uid = app.tencentAuth.getUserOpenID() {
                        // 获取uid
                        print("openId:\(uid)")
                    }
                    
                    if let token = app.tencentAuth.accessToken {
                        // 获取token
                        print("token:\(token)")
                    }
                    
                    if let name = res["nickname"] {
                        // 获取nickname
                        print("name:\(name)")
                    }
                    
                    if let sex = res["gender"] {
                        // 获取性别
                        print("sex:\(sex)")
                    }
                    
                    if let img = res["figureurl_qq_2"] {
                        // 获取头像
                        print("avatar:\(img)")
                    }
                    
                    
                    
                }
            } else {
                // 获取授权信息异常
                print("get user info error")
                print(response.errorMsg)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

