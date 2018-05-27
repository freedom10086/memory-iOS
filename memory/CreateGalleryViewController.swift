//
//  CreateGalleryViewController.swift
//  memory
//
//  Created by yang on 2018/5/28.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

class CreateGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    private var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usersCollectionView.dataSource = self
        usersCollectionView.delegate = self
    }

    
    // MARK: UICollectionViewDelegateFlowLayout
    //单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = (collectionView.frame.width - CGFloat(16)) / CGFloat(10)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
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
        var isLast = (indexPath.row == users.count - 1)
        isLast = (indexPath.row == 7)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: isLast ? "add_cell" : "cell", for: indexPath)
        if !isLast {
            let image =  cell.viewWithTag(1) as! UIImageView
            image.layer.cornerRadius = cell.frame.width / 2
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("==")
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
