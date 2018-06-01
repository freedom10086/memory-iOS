//
//  CreateGalleryViewController.swift
//  memory
//
//  Created by yang on 2018/5/28.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

// 创建 编辑 相册
class CreateGalleryViewController: UIViewController, UICollectionViewDataSource,
        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 回掉函数
    public var callback: ((Gallery?,Bool) -> Void)?
    // 为空创建 邀请按钮黑的
    public var gallery: Gallery?
    // 成员列表和邀请码
    public var memsAndCode: GalleryUsersAndCode?
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var descriptionInput: RitchTextView!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    // 新建的相册类型
    private var type = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: gallery == nil ? "创建" : "保存", style: .done, target: self, action: #selector(addOrSaveClick))
        
        if gallery == nil {
            usersCollectionView.isHidden = true
        } else {
            titleInput.text = gallery!.name
            descriptionInput.text = gallery!.description
            type = gallery!.type
            
            var btn: UIButton?
            if type == 1 {
                btn = btn1
            } else if type == 2 {
                btn = btn2
            } else if type == 3 {
                btn = btn3
            } else if type == 4 {
                btn = btn4
            }
            
            btn?.setBackgroundImage(#imageLiteral(resourceName: "chuangjianxiangce_biaoqian"), for: .normal)
            btn?.setTitleColor(UIColor.white, for: .normal)
            
            usersCollectionView.dataSource = self
            usersCollectionView.delegate = self
        }

        descriptionInput.placeholder = "相册描述"
        if self.memsAndCode == nil && gallery != nil {
            self.usersCollectionView.isHidden = true
            loadMembersAndCode()
        }
    }
    
    private func loadMembersAndCode() {
        Api.getGalleryMembers(galleryId: self.gallery!.id) { (memsAndCode, err) in
            if let res = memsAndCode {
                print(res)
                self.memsAndCode = res
                DispatchQueue.main.async {
                    self.upadteUsersCollectionView(mems: res.users)
                }
            } else {
                print("load members error \(err)")
            }
        }
    }
    
    private func upadteUsersCollectionView(mems: [User]) {
        self.usersCollectionView.reloadData()
    }

    // 保存或者新建相册
    @objc func addOrSaveClick() {
        let title = titleInput.text
        let des = descriptionInput.text
        
        if title == nil || title!.count == 0 || des == nil || des!.count == 0 {
            showAlert(title: "提示", message: "请输入必要信息")
            return
        }
        
        titleInput.resignFirstResponder()
        descriptionInput.resignFirstResponder()
        
        showLoadingView(title: "提交中", message: "请稍后...")
        Api.createGallery(name: title!, description: des!, type: type) { [weak self] (gallery, err) in
            DispatchQueue.main.async {
                let alertVc: UIAlertController
                if var g = gallery {
                    alertVc = UIAlertController(title: "提示", message: (self?.gallery == nil ? "创建相册成功" : "保存相册成功"), preferredStyle: .alert)
                    alertVc.addAction(UIAlertAction(title: "好", style: .cancel) { ac in
                        g.images = 0
                        g.users = 1
                        g.creater = Settings.user
                        self?.callback?(g,gallery == nil)
                        self?.navigationController?.popViewController(animated: true)
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
        }
    }
    
    @IBAction func tagButtonClick(_ sender: UIButton) {
        let p = sender.superview as! UIStackView
        for (k,item) in p.subviews.enumerated() {
            if item == sender {
                (item as! UIButton).setBackgroundImage(#imageLiteral(resourceName: "chuangjianxiangce_biaoqian"), for: .normal)
                (item as! UIButton).setTitleColor(UIColor.white, for: .normal)
                self.type = k + 1
            } else {
                (item as! UIButton).setBackgroundImage(#imageLiteral(resourceName: "chuangjianxiangce_biaoqian2"), for: .normal)
                (item as! UIButton).setTitleColor(self.view.tintColor, for: .normal)
            }
        }
    }
    

    // MARK: UICollectionViewDelegateFlowLayout
    //单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (collectionView.frame.width - CGFloat(16)) / CGFloat(10)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    private var collectionsCount: Int {
        let add = (self.memsAndCode?.inviteCode == nil) ? 0 : 1
        return (self.memsAndCode?.users.count ?? 1) + add
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionsCount
    }
    
    // collectionView的上下左右间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 8, bottom: 5, right: 5)
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
        let isLast = (indexPath.row >= (self.memsAndCode?.users.count ?? 1))
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: isLast ? "add_cell" : "cell", for: indexPath)
        if !isLast {
            let d = (self.memsAndCode?.users[indexPath.row] ?? self.gallery!.creater)
            let image =  cell.viewWithTag(1) as! UIImageView
            image.kf.setImage(with: URL(string: d!.avatar ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
            image.layer.cornerRadius = cell.frame.width / 2
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.reuseIdentifier == "add_cell" {
            MainViewController.invitePeople(name: gallery?.name, inviteCode: memsAndCode!.inviteCode!)
        }
    }
}
