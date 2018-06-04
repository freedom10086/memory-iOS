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
    private var noData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem =
            UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
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
                        self.noData = (gs.count == 0)
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noData {
            return 1
        }
        return self.datas.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if noData {
            cell = tableView.dequeueReusableCell(withIdentifier: "no_cell", for: indexPath)
            
        } else {
            let d = datas[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let albumImage = cell.viewWithTag(1) as! UIImageView
            let name = cell.viewWithTag(2) as! UILabel
            name.text = d.name
            Api.setGalleryCover(image: albumImage, url: d.cover, type: d.type)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FaceResultViewController {
            let source = sender as! UITableViewCell
            let index = self.tableView.indexPath(for: source)!
            dest.galleryId = self.datas[index.row].id
        }
    }

}
