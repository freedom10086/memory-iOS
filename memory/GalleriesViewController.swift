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
    private var pageSize = 1
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // 在标题栏添加搜索框
        let buttonWidth: CGFloat = 64
        let gap: CGFloat = 8
        let margin: CGFloat = 12
        
        self.title = nil
        let bounds = self.navigationController!.view.bounds
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                                width: bounds.width - margin * 2 - gap - buttonWidth, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "搜索相册"
        //searchBar.delegate = self //TODO
        searchBar.showsCancelButton = false
        //self.navigationController?.view.addSubview(searchBar)
        
        self.navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
        self.navigationItem.titleView?.addSubview(searchBar)
        
        // 在标题栏添加搜索按钮
        let textColor = UIColor.blue
        searchButton = UIButton(frame: CGRect(x: bounds.width - margin * 2 - buttonWidth, y: 4,
                                                  width: buttonWidth, height: 33))
        searchButton.setTitleColor(textColor, for: .normal)
        searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        searchButton.setTitle("上传照片", for: .normal)
        // set border
        searchButton.layer.masksToBounds = true
        searchButton.layer.cornerRadius = 6
        searchButton.layer.borderWidth = 1.0
        searchButton.layer.borderColor = textColor.cgColor
        self.navigationItem.titleView?.addSubview(searchButton)
        
        loadData()
    }
    
    private func loadData() {
        if isLoading { return }
        isLoading = true
        
        Api.loadGalleries(page: currentPage) { (galleries, err) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
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
                    
                    self.currentPage = self.currentPage + 1
                    self.isLoading = false
                } else {
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
        let comment = cell.viewWithTag(2) as! UILabel
        let username = cell.viewWithTag(3) as! UILabel
        
        name.text = d.name
        comment.text = "100"
        username.text = "创建人:\(d.creater.name)"
        
        backgroundImage.kf.setImage(with: URL(string: d.cover), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        backgroundImage.clipsToBounds = true
        backgroundImage.layer.cornerRadius = 8.0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement {
            print("load more next page is:\(currentPage)")
            loadData()
        }
    }
}
