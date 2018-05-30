//
//  UploadViewController.swift
//  memory
//
//  Created by yang on 2018/5/29.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit


// 上传图片页面
class UploadViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var deescriptionInput: UITextField!
    
    public var gallery: Gallery!
    private var images = [UploadResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "上传", style: .done, target: self, action: #selector(uploadClick))
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
    }
    
    @objc func uploadClick() {
        
        if images.count == 0 {
            showAlert(title: "提示", message: "你还没有上传图片")
            return
        }
        
        let des = deescriptionInput.text
        if des == nil || des!.count == 0 {
            showAlert(title: "提示", message: "请输入描述")
            return
        }
        
        for item in images {
            switch item.state {
            case .uploading(_):
                showAlert(title: "提示", message: "还有正在上传的图片.")
                return
            default:
                break
            }
        }
        

        var imageStr: String
        do {
            imageStr = String(data: try JSONEncoder().encode(images), encoding: .utf8)!
        } catch let err {
            showAlert(title: "编码错误", message: err.localizedDescription)
            return
        }
        
        deescriptionInput.resignFirstResponder()
        showLoadingView(title: "上传中", message: "请稍后...")
        Api.addImageToGallery(galleryId: gallery.id, images: imageStr, description: deescriptionInput.text!) { [weak self](count,err) in
            DispatchQueue.main.async {
                let alertVc: UIAlertController
                if let c = count {
                    print("success count \(c)")
                    alertVc = UIAlertController(title: "上传成功", message: "成功上传图片到相册:\(self?.gallery.name ?? "")", preferredStyle: .alert)
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
        }
    }
    @IBAction func cancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func upload(position: Int, imageData: Data) {
        Api.uploadImage(data: imageData) { (res, err) in
            if position > (self.images.count - 1) || self.images[position].data != imageData {
                print("upload done but not match may canceled before")
                return
            }
            
            DispatchQueue.main.async {
                if let r = res {
                    print("upload success \(r)")
                    self.images[position].state = .success
                    self.images[position].etag = r.etag
                    self.images[position].url = r.url
                } else {
                    print("upload error \(err)")
                    self.images[position].state = .failed
                    
                    let alert = UIAlertController(title: "图片上传失败", message:  "\(err)\n请选择要执行的操作", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (action) in
                        self.images.remove(at: position)
                        self.imagesCollectionView.deleteItems(at: [IndexPath(item: position, section: 0)])
                    }))
                    alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { (action) in
                        self.upload(position: position, imageData: imageData)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
                self.imagesCollectionView.reloadItems(at: [IndexPath(item: position, section: 0)])
            }
        }
    }
    
    // 点击触发选择图片
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == images.count {
            if images.count == 9 {
                showAlert(title: "提示", message: "最多上传9张图片")
                return
            }
            let handler: ((UIAlertAction) -> Void) = { alert in
                let picker = UIImagePickerController()
                picker.delegate = self
                if alert.title == "相册" {
                    picker.sourceType = .photoLibrary
                } else {
                    picker.sourceType = .camera
                }
                self.present(picker, animated: true, completion: nil)
            }
            
            let alert = UIAlertController(title: "请选择图片来源", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "相册", style: .default, handler: handler))
            alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: handler))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 相册选择回掉
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        // 最大图片宽度1080像素
        // rs 限制最大1M的附件
        let pickedImageData = ((info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage)?
            .scaleToSizeAndWidth(width: 2160, maxSize: 4096) //1024 4M
        picker.dismiss(animated: true, completion: nil)
        
        if let imageData = pickedImageData {
            images.append(UploadResult(url: "url", etag: "etag", data: imageData))
            let indexPath = IndexPath(item: images.count - 1, section: 0)
            self.imagesCollectionView.insertItems(at: [indexPath])
            upload(position: indexPath.row, imageData: imageData)
        } else {
            let alert = UIAlertController(title: "无法解析的图片,请换一张试试", message: "请选择适合的图片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }

    // 九宫格collection相关
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isLast = (indexPath.row == images.count)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: isLast ? "add_cell" : "cell", for: indexPath)
        if !isLast {
            let image =  cell.viewWithTag(1) as! UIImageView
            let progress = cell.viewWithTag(2) as! UIActivityIndicatorView
            
            if let d = images[indexPath.row].data {
                image.image = UIImage(data: d)
            }
            
            switch images[indexPath.row].state {
            case.uploading(_) :
                progress.startAnimating()
            case.failed:
                progress.stopAnimating()
            case.success:
                progress.stopAnimating()
            }
        }
        
        return cell
    }
    
    //单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = (collectionView.frame.width - CGFloat(30)) / CGFloat(5)
        return CGSize(width: cellSize, height: cellSize)
    }

    // collectionView的上下左右间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    
    // 单元的行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    // 每个小单元的列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let image = cell.viewWithTag(1) as! UIImageView
        let galleryName = cell.viewWithTag(2) as! UILabel
        
        if let cover = gallery.cover {
            image.kf.setImage(with: URL(string: cover), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        } else {
            image.image = #imageLiteral(resourceName: "image_placeholder")
        }
        
        galleryName.text = gallery.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
