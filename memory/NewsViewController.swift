//
//  NewsViewController.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

// 最新图片
class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var currentPage = 1
    private var totalPage = Int.max
    private var isLoading = false
    private var datas = [Image]()
    
    var testImage = "http://img4.duitang.com/uploads/item/201311/06/20131106211748_WrwS3.jpeg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = WaterFallCollectionViewLayout()
        layout.delegate = self
        //self.automaticallyAdjustsScrollViewInsets = false //修复collectionView头部空白
        collectionView.collectionViewLayout = layout
        
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            var subDatas = [Image]()
            
            for i in 0..<20 {
                subDatas.append(Image(id: i, url: self.testImage))
            }
            
            if self.currentPage == 1 {
                self.datas = subDatas
                self.collectionView.reloadData()
            } else {
                var indexs = [IndexPath]()
                for i in 0..<subDatas.count {
                    indexs.append(IndexPath(row: self.datas.count + i, section: 0))
                }
                self.datas.append(contentsOf: subDatas)
                print("here :\(subDatas.count)")
                self.collectionView.insertItems(at: indexs)
            }
            
            self.currentPage = self.currentPage + 1
            self.isLoading = false
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.layer.cornerRadius = 3.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 3.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        let d = datas[indexPath.row]
        let image = cell.viewWithTag(1) as! UIImageView
        //let title = cell.viewWithTag(2) as! UILabel
        //let author = cell.viewWithTag(3) as! UILabel
        //let likes = cell.viewWithTag(4) as! UILabel
        
        image.kf.setImage(with: URL(string: d.url), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        
        //title.text = d.title
        //author.text = d.author
        //likes.text = d.views
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement && currentPage < totalPage {
            print("load more next page is:\(currentPage) sum is:\(totalPage)")
            loadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}

extension NewsViewController: WaterFallLayoutDelegate {
    func itemHeightFor(indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        if datas[indexPath.row] != nil {
            return itemWidth + CGFloat(arc4random_uniform(UInt32(itemWidth))) + 30
        } else {
            return itemWidth
        }
    }
}
