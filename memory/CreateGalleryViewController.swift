//
//  CreateGalleryViewController.swift
//  memory
//
//  Created by yang on 2018/5/28.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

// 创建 编辑 相册
class CreateGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 为空创建 邀请按钮黑的
    public var gallery: Gallery?
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    private var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: gallery == nil ? "创建" : "保存", style: .done, target: self, action: #selector(addOrSaveClick))
        
        if gallery == nil {
            usersCollectionView.isHidden = true
        } else {
            usersCollectionView.dataSource = self
            usersCollectionView.delegate = self
        }

        users.append(User(id: 1, name: "", avatar: "", gender: "", created: "", token: ""))
    
    }

    // 保存或者新建相册
    @objc func addOrSaveClick() {
        let title = titleInput.text
        let des = descriptionInput.text
        
        if title == nil || title!.count == 0 || des == nil || des!.count == 0 {
            showAlert(title: "提示", message: "请输入必要信息")
            return
        }
    }
    
    // 邀请好友
    private func invitePeople() {
        let text = QQApiTextObject(text: "印迹相册加入邀请 请点击以下链接接受邀请")
        let req = SendMessageToQQReq(content: text)
        let res = QQApiInterface.send(req)
        print("share response \(res)")
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    //单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = (collectionView.frame.width - CGFloat(16)) / CGFloat(10)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    // collectionView的上下左右间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 5)
    }
    
    
    // 单元的行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    // 每个小单元的列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var isLast = (indexPath.row == users.count)
        isLast = (indexPath.row == 7)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: isLast ? "add_cell" : "cell", for: indexPath)
        if !isLast {
            let image =  cell.viewWithTag(1) as! UIImageView
            image.layer.cornerRadius = cell.frame.width / 2
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == users.count {
            invitePeople()
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
