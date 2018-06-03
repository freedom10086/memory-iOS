//
//  FaceResultViewController.swift
//  memory
//
//  Created by mac on 2018/6/3.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

class FaceResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var datas = [Image]()
    private var isLoading = false
    private var currentPage = 1
    private var pageSize = 100
    private var haveMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        let gvc = GalleryViewController(startIndex: indexPath.row,
//                                        itemsDataSource: self,
//                                        displacedViewsDataSource: self, vc: self)
//        gvc.updateLikeBlock = { image in
//            // 点赞回掉更新数据
//            for (i,item) in self.datas.enumerated() {
//                if item.id == image.id {
//                    self.datas[i] = image
//                    print("update like data")
//                    break
//                }
//            }
//        }
//        self.presentImageGallery(gvc)
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
//extension GridGalleryViewController: GalleryItemsDataSource {
//    func itemCount() -> Int {
//        return datas.count
//    }
//    
//    func provideGalleryItem(_ index: Int) -> GalleryItem {
//        let image = datas[index]
//        return GalleryItem.image(fetchImageBlock: { (compete) in
//            ImageDownloader.default.downloadImage(with: URL(string: image.url)!, options: [], progressBlock: nil) {
//                (image, error, url, data) in
//                compete(image)
//            }
//        }, image: image)
//    }
//}
//
//extension GridGalleryViewController: GalleryDisplacedViewsDataSource {
//    
//    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
//        if let cell =  collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
//            return (cell.viewWithTag(1) as! UIImageView)
//        }
//        return nil
//    }
//}
