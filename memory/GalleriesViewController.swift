//
//  GalleriesViewController.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

// 相册列表
class GalleriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //数据
    private var datas = [Gallery]()
    private var testImage = "http://img4.duitang.com/uploads/item/201311/06/20131106211748_WrwS3.jpeg"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(170)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let d = datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let backgroundImage = cell.viewWithTag(4) as! UIImageView
        let name = cell.viewWithTag(1) as! UILabel
        let comment = cell.viewWithTag(2) as! UILabel
        let username = cell.viewWithTag(3) as! UILabel
        
        backgroundImage.kf.setImage(with: URL(string: testImage), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        backgroundImage.clipsToBounds = true
        backgroundImage.layer.cornerRadius = 8.0
        //forceTouch
        //if traitCollection.forceTouchCapability == .available {
        //    registerForPreviewing(with: self, sourceView: cell)
        //}
        
        return cell
    }
}
