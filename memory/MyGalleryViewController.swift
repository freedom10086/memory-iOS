//
//  MyGalleryViewController.swift
//  memory
//
//  Created by mac on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

// 单个相册页面
class MyGalleryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var galleryId: Int!
    public var gallery: Gallery?
    public var membersAndCode: GalleryUsersAndCode?
    public var deleteCallback: ((Int)->Void)?
    public var updateCallback: ((Gallery)->Void)?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBgImageView: UIImageView!
    @IBOutlet weak var galleryType: UILabel!
    @IBOutlet weak var galleryName: UILabel!
    @IBOutlet weak var imagesCount: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var peoplesLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    private var rsRefreshControl: RSRefreshControl!
    
    private var datas = [ImageGroup]()
    private var pageSize = 1000
    private var currentPage = 1
    private var clickPosition = 0
    private var haveMore = true
    
    private var loading = false
    open var isLoading: Bool {
        get {
            return loading
        }
        set {
            loading = newValue
            let footer = tableView.tableFooterView as? LoadMoreView
            if !loading {
                footer?.endLoading(haveMore: haveMore)
            } else {
                footer?.startLoading()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "xiangcexiangqing_gengduo"), style: .plain, target: self, action: #selector(moreClick)),
            UIBarButtonItem(image: #imageLiteral(resourceName: "xiangqingxiangqing_shezhi"), style: .plain, target: self, action: #selector(settingClick))
        ]
        
        //init refresh control
        rsRefreshControl = RSRefreshControl()
        rsRefreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.addSubview(rsRefreshControl!)
        tableView.tableFooterView = LoadMoreView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        
        //if gallery == nil we show load from web
        if let ga = gallery {
            galleryId = ga.id
            setNavView(gallery: ga)
        }
        
        rsRefreshControl?.beginRefreshing()
        loadData()
        loadMembersAndCode()
    }
    
    @objc private func reloadData() {
        currentPage = 1
        loadData()
    }
    
    private func loadData() {
        if isLoading { return }
        isLoading = true
        
        if gallery == nil {
            Api.loadGallery(id: galleryId, page: currentPage, pageSize: pageSize) { [weak self] (gallery, err) in
                self?.handleRes(gallery: gallery, imageGroups: gallery?.groups, err: err)
            }
        } else {
            Api.loadGalleryGroups(id: galleryId, page: currentPage, pageSize: pageSize) { [weak self] (imageGroups, err) in
                self?.handleRes(gallery: nil, imageGroups: imageGroups, err: err)
            }
        }
    }
    
    private func handleRes(gallery: Gallery?, imageGroups: [ImageGroup]?, err: String) {
        DispatchQueue.main.async {
            if self.gallery == nil && gallery != nil {
                self.gallery = gallery
                self.setNavView(gallery: gallery!)
            }
            
            print("success")
            self.rsRefreshControl?.endRefreshing(message: imageGroups != nil ? "刷新成功...":"刷新失败...")
            if let gs = imageGroups {
                if self.currentPage == 1 {
                    self.datas = gs
                    self.tableView.reloadData()
                } else {
                    var indexs = [IndexPath]()
                    for i in 0..<gs.count {
                        indexs.append(IndexPath(row: self.datas.count + i, section: 0))
                    }
                    self.datas.append(contentsOf: gs)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexs, with: .automatic)
                    self.tableView.endUpdates()
                }
                
                if gs.count < self.pageSize {
                    self.haveMore = false
                } else {
                    self.haveMore = true
                    self.currentPage = self.currentPage + 1
                }
            } else {
                if self.currentPage == 1 {
                    self.datas = []
                    self.tableView.reloadData()
                }
                self.showAlert(title: "加载错误", message: err)
            }
            
            self.isLoading = false
        }
    }
    
    private func loadMembersAndCode() {
        Api.getGalleryMembers(galleryId: galleryId) { (memsAndCode, err) in
            if let res = memsAndCode {
                print(res)
                self.membersAndCode = res
            } else {
                print("load members error \(err)")
            }
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        // 取消大标题栏
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setNavView(gallery: Gallery) {
        if gallery.exit {
           self.addButton.isHidden = true
        }
        
        self.title = gallery.name
        Api.setGalleryCover(image: navBgImageView, url: gallery.cover, type: gallery.type)
        galleryType.text = "\(Api.getGalleryType(type: gallery.type) ?? "未指定")相册"
        galleryName.text = gallery.name
        imagesCount.text = "\(gallery.images) 张图片"
        descriptionLabel.text = gallery.description
        peoplesLabel.text = "\(gallery.users) 个群成员"
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickPosition = indexPath.row
        print("click \(clickPosition)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let gvc = GalleryViewController(startIndex: 0, itemsDataSource: self, displacedViewsDataSource: self, vc: self)
        gvc.updateLikeBlock = { image in
            // 点赞回掉更新数据
            Loop:
                for (j,imageGroup) in self.datas.enumerated() {
                    for (i,item) in (imageGroup.images ?? []).enumerated() {
                        if item.id == image.id {
                            self.datas[j].images![i] = image
                            print("update like data")
                            break Loop
                        }
                }
            }
            
        }
        self.presentImageGallery(gvc)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let d = datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let avatarImage = cell.viewWithTag(1) as! UIImageView
        let username = cell.viewWithTag(2) as! UILabel
        let timeLabel = cell.viewWithTag(3) as! UILabel
        let image = cell.viewWithTag(4) as! UIImageView
        let description = cell.viewWithTag(5) as! UILabel
        let imageCountLabel = cell.viewWithTag(6) as! UILabel
        
        let likeBtn = cell.viewWithTag(7) as! UIButton
        let commentBtn = cell.viewWithTag(8) as! UIButton
        
        let likes: Int = (d.images?.reduce(0, { (rs, image) -> Int in
            return rs + image.likes
        })) ?? 0
        
        let comments: Int = (d.images?.reduce(0, { (rs, image) -> Int in
            return rs + image.comments
        })) ?? 0
        
        likeBtn.setTitle(" \(likes)", for: .normal)
        commentBtn.setTitle(" \(comments)", for: .normal)
        
        avatarImage.kf.setImage(with: URL(string: d.creater?.avatar ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        username.text = d.creater?.name ?? "Unknown"
        timeLabel.text = d.created
        image.kf.setImage(with: URL(string: d.images?[0].url ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        description.text = d.description ?? d.images?[0].description ?? ""
        imageCountLabel.text = "多图"
        imageCountLabel.isHidden = d.images?.count ?? 0 <= 1
        
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination)
        if segue.identifier == "galleryToNew" {
            if let dest = segue.destination as? UINavigationController,
                let upVc = dest.childViewControllers[0] as? UploadViewController {
                upVc.gallery = self.gallery!
            }
        }
    }
    
    @objc func settingClick() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "createGalleryVc") as! CreateGalleryViewController
        vc.memsAndCode = self.membersAndCode
        vc.title = "编辑相册"
        vc.gallery = self.gallery
        vc.callback = { (gallery, create) in
            if !create ,let g = gallery {
                self.gallery = g
                self.setNavView(gallery: g)
            }
        }
        self.show(vc, sender: self)
    }
    
    @objc func moreClick() {
        let sheet = UIAlertController(title: "操作", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "网格视图", style: .default) { action in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "gridGalleryViewController") as! GridGalleryViewController
            vc.galleryId = self.galleryId
            vc.title = self.gallery?.name
            self.show(vc, sender: self)
        })
        
        if let inviteCode = self.membersAndCode?.inviteCode {
            sheet.addAction(UIAlertAction(title: "邀请好友", style: .default) { action in
                MainViewController.invitePeople(name: self.gallery?.name, inviteCode: inviteCode)
            })
        }
        
        if Settings.uid == gallery?.creater?.id {
            sheet.addAction(UIAlertAction(title: "删除相册", style: .default) { action in
                print("===delete===")
                //TODO 管理员逻辑
            })
        } else {
            if !(gallery?.exit ?? false) {
                sheet.addAction(UIAlertAction(title: "退出相册", style: .default) { action in
                    let alert2 = UIAlertController(title: "提示", message: "是否保留相册？不保留则删除相册", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "是", style: .default, handler: { (ac) in
                        self.deleteGallery(keep: true)
                    }))
                    
                    alert2.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (ac) in
                        self.deleteGallery(keep: false)
                    }))
                    
                    self.present(alert2, animated: true, completion: nil)
                })
            }
        }
        
        sheet.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func deleteGallery(keep: Bool) {
        Api.deleteGallery(galleryId: self.galleryId, keep: keep) { (affets,err) in
            DispatchQueue.main.async {
                if let a = affets {
                    print("=======delete \(a)===")
                    self.showBackAlert(title: "提示", message: keep ? "已成功退出相册,相册会保持在你退出的状态"
                        : "已成功删除相册")
                    if !keep {
                        self.deleteCallback?(self.galleryId)
                    } else {
                        self.updateCallback?(self.gallery!)
                    }
                } else {
                    self.showAlert(title: "错误", message: err)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement && haveMore {
            print("load more next page is:\(currentPage)")
            loadData()
        }
    }
    
}

// The GalleryItemsDataSource provides the items to show
extension MyGalleryViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return datas[clickPosition].images?.count ?? 0
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let image = datas[clickPosition].images![index]
        return GalleryItem.image(fetchImageBlock: { (compete) in
            ImageDownloader.default.downloadImage(with: URL(string: image.url)!, options: [], progressBlock: nil) {
                (image, error, url, data) in
                compete(image)
            }
        }, image: image)
    }
}

extension MyGalleryViewController: GalleryDisplacedViewsDataSource {
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        if let cell =  tableView.cellForRow(at: IndexPath(row: clickPosition, section: 0)) {
            return (cell.viewWithTag(4) as! UIImageView)
        }
        return nil
    }
}

extension UIImageView: DisplaceableView {}

