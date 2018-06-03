//
//  FaceViewController.swift
//  memory
//
//  Created by mac on 2018/6/3.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit

class FaceViewController: UITableViewController {
    
    private var datas = [Gallery]()
    private var isLoading = false
    private var currentPage = 1
    private var pageSize = 100
    private var haveMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func loadData() {
        if isLoading { return }
        isLoading = true
        Api.loadGalleries(page: currentPage, pageSize: pageSize, query: nil) { (galleries, err) in
            DispatchQueue.main.async {
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
                        self.haveMore = false
                    } else {
                        self.haveMore = true
                        self.currentPage = self.currentPage + 1
                    }
                } else {
                    self.haveMore = false
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.datas.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let d = datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let albumImage = cell.viewWithTag(1) as! UIImageView
        let name = cell.viewWithTag(2) as! UILabel
        
        name.text = d.name
        
        Api.setGalleryCover(image: albumImage,
                            url: d.groups?[0].images?[0].url ?? d.cover, type: d.type)
        
        return cell
    }

   
}
