//
//  CommentViewController.swift
//  memory
//
//  Created by yang on 2018/5/29.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

// 评论列表页面
class CommentViewController: UIViewController {
    
    public var image: Image?

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var galleryName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var replyView: SimpleReplyView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        replyView.placeholder = "回复"
        
        replyView.onSubmitClick { content in
            if content.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
                //print("message is:||\(content)||len:\(content.count)")
                self.replyView.isSending = true
                
                //TODO POST API
            }
        }
    }

  
    @IBAction func closeClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
