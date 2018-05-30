//
//  MyGalleryViewController.swift
//  memory
//
//  Created by mac on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

// 单个相册页面
class MyGalleryViewController: UIViewController {
    
    public var galleryId: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("======")
    }

    override func viewWillAppear(_ animated: Bool) {
        // 取消大标题栏
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .never
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
