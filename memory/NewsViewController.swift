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
    private var datas = [ImageGroup]()
    
    private var currentPage = 1
    private var pageSize = 30
    private var haveMore = false

    private var isLoading = false
    private var emptyPlaceholderText = "加载中"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadData))
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = WaterFallCollectionViewLayout()
        layout.delegate = self
        //self.automaticallyAdjustsScrollViewInsets = false //修复collectionView头部空白
        collectionView.collectionViewLayout = layout
    
        self.navigationItem.title = "最新"
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 大标题栏
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    @objc private func reloadData() {
        currentPage = 1
        emptyPlaceholderText = "加载中"
        loadData()
    }
    
    func loadData() {
        isLoading = true
        Api.loadNewsImages(page: currentPage, pageSize: pageSize) { (imageGroups, err) in
            if let subDatas = imageGroups {
                if self.currentPage == 1 {
                    self.datas = subDatas
                    self.collectionView.reloadData()
                } else {
                    var indexs = [IndexPath]()
                    for i in 0..<subDatas.count {
                        indexs.append(IndexPath(row: self.datas.count + i, section: 0))
                    }
                    self.datas.append(contentsOf: subDatas)
                    self.collectionView.insertItems(at: indexs)
                }
                
                if subDatas.count < self.pageSize {
                    self.haveMore = false
                } else {
                    self.haveMore = true
                    self.currentPage = self.currentPage + 1
                }
                self.emptyPlaceholderText = "暂无数据"
            } else {
                if self.currentPage == 1 {
                    self.datas = []
                    self.emptyPlaceholderText = "加载错误，请刷新"
                    self.collectionView.reloadData()
                    
                }
                self.showAlert(title: "加载错误", message: err)
            }
            
            self.isLoading = false
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if datas.count == 0 {//no data avaliable
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width,
                                              height: collectionView.bounds.height))
            label.text = emptyPlaceholderText
            label.textColor = UIColor.darkGray
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = UIColor.lightGray
            label.sizeToFit()
            
            collectionView.backgroundView = label
            return 1
        } else {
            collectionView.backgroundView = nil
            return 1
        }
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
        let uploader = cell.viewWithTag(2) as! UILabel
        let count = cell.viewWithTag(3) as! UILabel
        
        if let url = d.images?[0].url {
            image.kf.setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        } else {
            image.image = #imageLiteral(resourceName: "image_placeholder")
        }
        
        if let username = d.creater?.name {
            uploader.text = username
        } else {
            uploader.text = nil
        }
        
        count.text = "\(d.images?.count ?? 0)张"

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement && haveMore {
            print("load more next page is:\(currentPage)")
            loadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension NewsViewController: WaterFallLayoutDelegate {
    func itemHeightFor(indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        if datas[indexPath.row].images != nil && datas[indexPath.row].images!.count > 0 {
            return itemWidth + CGFloat(arc4random_uniform(UInt32(itemWidth)))
        } else {
            return itemWidth
        }
    }
}
