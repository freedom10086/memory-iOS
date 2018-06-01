//
//  MessageViewController.swift
//  memory
//
//  Created by yang on 2018/5/29.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit


// 消息页面
class MessageViewController: UITableViewController {

    private var datas = [Message]()
    
    private var pageSize = 1000
    private var currentPage = 1
    private var clickPosition = 0
    private var haveMore = true
    private var placeholderText = "加载中"
    
    private var loading = false
    open var isLoading: Bool {
        get {
            return loading
        }
        set {
            loading = newValue
            let footer = tableView.tableFooterView as? LoadMoreView
            if !loading {
                footer?.isHidden = false
                footer?.endLoading(haveMore: haveMore)
            } else {
                if self.datas.count < 8 {
                    footer?.isHidden = true
                } else {
                    footer?.startLoading()
                }
            }
        }
    }
    
    private var rsRefreshControl: RSRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init refresh control
        rsRefreshControl = RSRefreshControl()
        rsRefreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.addSubview(rsRefreshControl!)
        tableView.tableFooterView = LoadMoreView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        
        rsRefreshControl?.beginRefreshing()
        loadData()
    }
    
    @objc private func reloadData() {
        currentPage = 1
        placeholderText = "加载中"
        loadData()
    }
    
    private func loadData() {
        if isLoading { return }
        isLoading = true
        
        Api.getMessages(page: currentPage, pageSize: pageSize) { (messages, err) in
            DispatchQueue.main.async {
                self.rsRefreshControl?.endRefreshing(message: messages != nil ? "刷新成功...":"刷新失败...")
                if let ms = messages {
                    if self.currentPage == 1 {
                        self.datas = ms
                        self.tableView.reloadData()
                    } else {
                        var indexs = [IndexPath]()
                        for i in 0..<ms.count {
                            indexs.append(IndexPath(row: self.datas.count + i, section: 0))
                        }
                        self.datas.append(contentsOf: ms)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexs, with: .automatic)
                        self.tableView.endUpdates()
                    }
                    
                    if ms.count < self.pageSize {
                        self.haveMore = false
                    } else {
                        self.haveMore = true
                        self.currentPage = self.currentPage + 1
                    }
                    self.placeholderText = "暂无消息"
                } else {
                    if self.currentPage == 1 {
                        self.datas = []
                        self.tableView.reloadData()
                    }
                    self.placeholderText = "加载失败"
                    self.showAlert(title: "加载错误", message: err)
                }
                
                self.isLoading = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if datas.count == 0 {//no data avaliable
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            label.text = placeholderText
            label.textColor = UIColor.darkGray
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = UIColor.lightGray
            label.sizeToFit()
            
            tableView.backgroundView = label
            tableView.separatorStyle = .none
            return 0
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let d = datas[indexPath.row]
        let avatar = cell.viewWithTag(1) as! UIImageView
        let name = cell.viewWithTag(2) as! UILabel
        let action = cell.viewWithTag(3) as! UILabel
        let content = cell.viewWithTag(4) as! UILabel
        let imageView = cell.viewWithTag(5) as! UIImageView
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.kf.setImage(with: URL(string: d.creater?.avatar ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        name.text = d.creater?.name ?? "Unknown"
        action.text = (d.type == 0 ? "赞了你的照片" : "评论了你的照片")
        content.text = (d.type == 0 ? nil : d.content ?? "")
        imageView.kf.setImage(with: URL(string: d.image?.url ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        
        return cell
    }
}
