//
//  CommentViewController.swift
//  memory
//
//  Created by yang on 2018/5/29.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

// 评论列表页面
class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var image: Image!

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var galleryName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var replyView: SimpleReplyView!
    private var rsRefreshControl: RSRefreshControl!
    
    
    private var currentPage = 1
    private var pageSize = 1000
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
    
    
    private var datas = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.applicationWindow.windowLevel = UIWindowLevelNormal
        
        self.title = "评论"
        self.tableView.dataSource = self
        self.tableView.delegate = self

        //init refresh control
        rsRefreshControl = RSRefreshControl()
        rsRefreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.addSubview(rsRefreshControl!)
        self.tableView.tableFooterView = LoadMoreView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        
        
        replyView.placeholder = "回复"
        replyView.onSubmitClick { content in
            if content.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
                //print("message is:||\(content)||len:\(content.count)")
                self.replyView.isSending = true
                
                Api.comment(imageId: self.image!.id, content: content, callback: { (comment,err) in
                    DispatchQueue.main.async {
                        if var c = comment {
                            c.creater = Settings.user!
                            self.datas.append(c)
                            print("success")
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: self.datas.count - 1, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                            self.replyView.clearText(hide: true)
                        } else {
                            self.showAlert(title: "错误", message: err)
                        }
                        
                        self.replyView.contentView?.resignFirstResponder()
                        self.replyView.isSending = false
                    }
                })
            }
        }
        
        setUpView()
        rsRefreshControl?.beginRefreshing()
        loadData()
    }
    
    private func setUpView() {
        avatarImage.kf.setImage(with: URL(string: image.creater?.avatar ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        username.text = image.creater?.name ?? "Unknown"
        time.text = image.created
        descriptionLabel.text = image.description ?? ""
        mainImageView.kf.setImage(with: URL(string: image.url), placeholder: #imageLiteral(resourceName: "image_placeholder"))
    }
    
    @objc private func reloadData() {
        currentPage = 1
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.applicationWindow.windowLevel = UIWindowLevelStatusBar + 1
    }
    
    private func loadData() {
        Api.getComments(imageId: self.image.id, page: self.currentPage, pageSize: self.pageSize) { comments, err in
            DispatchQueue.main.async {
                self.rsRefreshControl?.endRefreshing(message: comments != nil ? "刷新成功...":"刷新失败...")
                if let cs = comments {
                    if self.currentPage == 1 {
                        self.datas = cs
                        self.tableView.reloadData()
                    } else {
                        var indexs = [IndexPath]()
                        for i in 0..<cs.count {
                            indexs.append(IndexPath(row: self.datas.count + i, section: 0))
                        }
                        self.datas.append(contentsOf: cs)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexs, with: .automatic)
                        self.tableView.endUpdates()
                    }
                    
                    if cs.count < self.pageSize {
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let d = datas[indexPath.row]
        let avatar = cell.viewWithTag(1) as! UIImageView
        let name = cell.viewWithTag(2) as! UILabel
        let time = cell.viewWithTag(3) as! UILabel
        let content = cell.viewWithTag(4) as! UILabel
        
        avatar.kf.setImage(with: URL(string: d.creater.avatar ?? ""), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        name.text = d.creater.name ?? "Unknown"
        time.text = d.created
        content.text = d.content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = datas.count - 1
        if !isLoading && indexPath.row == lastElement && haveMore {
            print("load more next page is:\(currentPage)")
            loadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

  
    @IBAction func closeClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
