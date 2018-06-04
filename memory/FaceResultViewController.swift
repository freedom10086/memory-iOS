//
//  FaceResultViewController.swift
//  memory
//
//  Created by mac on 2018/6/3.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

class FaceResultViewController: UIViewController, UICollectionViewDataSource,
        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var galleryId: Int!
    
    private var datas: [Image] {
        get {
            return isInPickMode ? datasNormal : datasResult
        }
        
        set {
            if isInPickMode {
                datasNormal = newValue
            } else {
                datasResult = newValue
            }
        }
    }
    
    
    private var datasNormal = [Image]()
    private var datasResult = [Image]()
    
    private var isLoading = false
    private var currentPage = 1
    private var pageSize = 1000
    private var haveMore = true
    
    private var isInPickMode = true {
        didSet {
            if isInPickMode {
                self.title = "请选择要识别的图片"
            } else {
                self.title = "识别结果"
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "重选", style: .done, target: self, action: #selector(reSelectClick))
            }
        }
    }
    
    @objc private func reSelectClick() {
        self.navigationItem.rightBarButtonItem = nil
        self.isInPickMode = true
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "请选择要识别的图片"
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func loadData() {
        if isLoading { return }
        isLoading = true
        
        Api.getGalleryGridList(galleryId: galleryId, page: currentPage, pageSize: pageSize) { (images, err) in
            DispatchQueue.main.async {
                if let gs = images {
                    if self.currentPage == 1 {
                        self.datas = gs
                        self.collectionView.reloadData()
                    } else {
                        var indexs = [IndexPath]()
                        for i in 0..<gs.count {
                            indexs.append(IndexPath(row: self.datas.count + i, section: 0))
                        }
                        self.datas.append(contentsOf: gs)
                        self.collectionView.insertItems(at: indexs)
                    }
                    
                    if gs.count < self.pageSize {
                        self.haveMore = false
                    } else {
                        self.haveMore = true
                        self.currentPage = self.currentPage + 1
                    }
                } else {
                    self.haveMore = false
                    if self.currentPage == 1 {
                        self.datas = []
                        self.collectionView.reloadData()
                    }
                    self.showAlert(title: "加载错误", message: err)
                }
                
                self.isLoading = false
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let d = datas[indexPath.row]
        let image = cell.viewWithTag(1) as! UIImageView
        image.kf.setImage(with: URL(string: d.url))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if isInPickMode {
            
             //http://203.195.129.198:5000/?user_img_url=http://n1image.hjfile.cn/shetuan/2017-05-17-1495016837-986-732.jpg&image_list_url=http://n1image.hjfile.cn/shetuan/2017-05-17-1495016837-986-732.jpg
            let d = datas[indexPath.row]
            var iis = [String]()
            for item in datas {
                if item.url != d.url {
                    iis.append(item.url)
                }
            }
            
            if iis.count <= 0 {
                return
            }
            
            self.showLoadingView(title: "识别中", message: "请稍后...")
            isInPickMode = false
            self.datas = [d]
            self.collectionView.reloadData()
            Api.detectFace(image: d.url, images: iis) { (images, err) in
                DispatchQueue.main.async {
                    var alertVc: UIAlertController?
                    if let us = images {
                        if us.count == 0 {
                            alertVc = UIAlertController(title: "提示", message: "无识别结果", preferredStyle: .alert)
                            alertVc?.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                            self.isInPickMode = true
                        } else {
                            print("count \(us.count)")
                            self.isInPickMode = false
                            for ii in us {
                                print(ii)
                            }
                            for item in us {
                                if let i = self.findData(url: String(item.trimmingCharacters(in: CharacterSet(charactersIn: "'")))) {
                                    self.datas.append(i)
                                }
                            }
                            
                            self.collectionView.reloadData()
                        }
                    } else {
                        alertVc = UIAlertController(title: "错误", message: err, preferredStyle: .alert)
                        alertVc?.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                        self.isInPickMode = true
                    }
                
                    
                    // 取消loading
                    self.dismiss(animated: true, completion: {
                        if let ac = alertVc {
                            self.present(ac, animated: true)
                        }
                    })
                }
            }
        } else {
            let gvc = GalleryViewController(startIndex: indexPath.row,
                                            itemsDataSource: self,
                                            displacedViewsDataSource: self, vc: self)
            gvc.updateLikeBlock = { image in
                // 点赞回掉更新数据
                for (i,item) in self.datas.enumerated() {
                    if item.id == image.id {
                        self.datas[i] = image
                        print("update like data")
                        break
                    }
                }
            }
            self.presentImageGallery(gvc)
        }
    }
    
    public func findData(url: String) -> Image? {
        for item in self.datasNormal {
            if url.range(of: item.url) != nil {
                return item
            }
        }
        
        return nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement && haveMore {
            print("load more next page is:\(currentPage)")
            loadData()
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    //单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (collectionView.frame.width - CGFloat(20)) / CGFloat(3)
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
    
}

// The GalleryItemsDataSource provides the items to show
extension FaceResultViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return datas.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let image = datas[index]
        return GalleryItem.image(fetchImageBlock: { (compete) in
            ImageDownloader.default.downloadImage(with: URL(string: image.url)!, options: [], progressBlock: nil) {
                (image, error, url, data) in
                compete(image)
            }
        }, image: image)
    }
}

extension FaceResultViewController: GalleryDisplacedViewsDataSource {
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        if let cell =  collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
            return (cell.viewWithTag(1) as! UIImageView)
        }
        return nil
    }
}
