//
//  FeedbackViewController.swift
//  memory
//
//  Created by yang on 2018/5/29.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import MessageUI

// 反馈
class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var contentInput: UITextView!
    private var version: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "提交", style: .done, target: self, action: #selector(submit))
        
        //CFBundleVersion
        if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = " - 版本: \(v)"
        }
        
        let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int ?? 1
        print("current versionCode:\(versionCode)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    @objc private func submit() {
        let title = titleInput.text
        let content = contentInput.text
        
        if title == nil || title!.count == 0 || content == nil || content!.count == 0 {
            showAlert(title: "提示", message: "请输入必要信息")
            return
        }
        
        print("feed back")
        let toRecipents = ["nomopfyin@tencent.com","daxu@tencent.com","echomxmeng@tencent.com",
                           "ethanji@tencent.com","joefreychen@tencent.com","qhwang@tencent.com",
                           "rangerluo@tencent.com","robinwzhang@tencent.com","zhenrzhang@tencent.com"]
        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(title! + (version == nil ? "" : version!))
            mc.setMessageBody(content!, isHTML: false)
            mc.setToRecipients(toRecipents)
            self.present(mc, animated: true, completion: nil)
        } else {
            alert(title: "无法提交", message: "没有可用的邮件客户端", bdy: "好的")
        }
    }
    
    
    func alert(title: String?, message: String?, bdy: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: bdy, style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        let delayTime = DispatchTime.now().uptimeNanoseconds + 2 * NSEC_PER_SEC
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: delayTime)) {
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

}
