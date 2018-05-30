//
//  GalleriesViewController.swift
//  memory
//
//  Created by yang on 2018/5/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

// 相册列表
class GalleriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //数据
    private var datas = [Gallery]()
    private var searchBar: UISearchBar!
    private var searchButton: UIButton!
    
    private var currentPage = 1
    private var pageSize = 30
    private var haveMore = false
    var rsRefreshControl: RSRefreshControl!
    
    private var loading = false
    open var isLoading: Bool {
        get {
            return loading
        }
        set {
            loading = newValue
            let footer = tableView.tableFooterView as? LoadMoreView
            if self.currentPage == 1 {
                footer?.isHidden = true
            } else {
                footer?.isHidden = false
                if !loading {
                    footer?.endLoading(haveMore: haveMore)
                } else {
                    footer?.startLoading()
                }
            }
        }
    }
    
    private var haveLoaded = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //init refresh control
        rsRefreshControl = RSRefreshControl()
        rsRefreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.addSubview(rsRefreshControl!)
        tableView.tableFooterView = LoadMoreView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        
        // 在标题栏添加搜索框
        let margin: CGFloat = 12
        self.title = nil
        let bounds = self.navigationController!.view.bounds
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: bounds.width - margin * 2, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "搜索相册"
        //searchBar.delegate = self //TODO
        //searchBar.showsCancelButton = true
        self.navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
        self.navigationItem.titleView?.addSubview(searchBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        if Settings.accessToken != nil && !haveLoaded {
            haveLoaded = true
            rsRefreshControl?.beginRefreshing()
            loadData()
        }
    }
    
    @objc private func reloadData() {
        currentPage = 1
        loadData()
    }
    
    private func loadData() {
        if isLoading { return }
        isLoading = true
        
        Api.loadGalleries(page: currentPage, pageSize: pageSize) { (galleries, err) in
            DispatchQueue.main.async {
                self.rsRefreshControl?.endRefreshing(message: galleries != nil ? "刷新成功...":"刷新失败...")
                if let gs = galleries {
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
                        self.haveMore = true
                        self.currentPage = self.currentPage + 1
                    } else {
                        self.haveMore = false
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(180)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let d = datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let backgroundImage = cell.viewWithTag(4) as! UIImageView
        let name = cell.viewWithTag(1) as! UILabel
        let peoples = cell.viewWithTag(2) as! UILabel
        let username = cell.viewWithTag(3) as! UILabel
        
        name.text = d.name
        peoples.text = d.users > 0 ? "\(d.users)人" : nil
        username.text = "创建人:\(d.creater?.name ?? "Unknown")"
        
        var cover = d.cover
        if cover == nil {
            cover = d.groups?[0].images?[0].url
        }
        
        if let c = cover {
            backgroundImage.kf.setImage(with: URL(string: c), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        } else {
            backgroundImage.image = #imageLiteral(resourceName: "image_placeholder")
        }
        
        backgroundImage.clipsToBounds = true
        backgroundImage.layer.cornerRadius = 8.0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement && haveMore {
            print("load more next page is:\(currentPage)")
            loadData()
        }
    }
    
    @objc func goToUploadImage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "uploadImageNavVc")
        self.present(vc!, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MyGalleryViewController,
            let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)!
            dest.title = datas[index.row].name
            dest.gallery = datas[index.row]
        }
    }
}
