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
    
    private var images = [UploadResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "上传", style: .done, target: self, action: #selector(uploadClick))
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
    }
    
    @objc func uploadClick() {
    
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
            images.append(UploadResult(url: "1", etag: "2", data: imageData))
            let indexPath = IndexPath(item: images.count - 1, section: 0)
            self.imagesCollectionView.insertItems(at: [indexPath])
            
            //uploadImage(position: indexPath.row, imageData: imageData)
            
            // TODO 真正的上传
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
                progress.startAnimating()
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
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
