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
    
    // 从邀请链接打开此值不为空
    public static var inviteCode: String?
    
    var isShowLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.checkMessage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let accessToken = Settings.accessToken {
            print("认证有效 过期:\(Settings.expiresIn)")
            
            if let inviteCode = MainViewController.inviteCode {
                Api.checkInviteCode(inviteCode: inviteCode) { (gallery, err) in
                    DispatchQueue.main.async {
                        if let g = gallery {
                            let alert = UIAlertController(title: "相册邀请", message: "\(g.creater!.name!) 邀请你加入相册 \(g.name) 是否同意邀请?", preferredStyle: .alert)
                            let action = UIAlertAction(title: "同意", style: .default, handler: { (ac) in
                                self.joinGallery(gallery: g, inviteCode: inviteCode)
                            })
                            alert.addAction(action)
                            alert.addAction(UIAlertAction(title: "不同意", style: .cancel, handler: { (ac) in
                                MainViewController.inviteCode = nil
                            }))
                            self.present(alert, animated: true)
                        } else {
                            self.showAlert(title: "加入邀请失败", message: err)
                        }
                    }
                }
            }
        } else if !isShowLogin {
            print("认证无效 过期:\(Settings.expiresIn)")
            //login
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "loginNavViewController")
            self.present(dest!, animated: true, completion: nil)
            isShowLogin = true
            return
        }
    }
    
    // accept invite join gallery
    public func joinGallery(gallery: Gallery, inviteCode: String) {
        Api.joinGallery(inviteCode: inviteCode) { (gallery, err) in
            MainViewController.inviteCode = nil
            DispatchQueue.main.async {
                if let g = gallery {
                    let alert = UIAlertController(title: "提示", message: "成功加入相册 \(g.name)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    self.showAlert(title: "加入邀请失败", message: err)
                }
            }
        }
    }
    
    // 检查未读消息
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
    
    // 邀请好友
    public static func invitePeople(name: String?, inviteCode: String) {
        let text = QQApiTextObject(text: "我邀请你加入印迹相册【\(name ?? "")】 请点击以下链接接受邀请 \(Api.baseUrl)/invite-page.html?invitecode=\(inviteCode)")
        let req = SendMessageToQQReq(content: text)
        let res = QQApiInterface.send(req)
        print("share response \(res)")
    }
}
