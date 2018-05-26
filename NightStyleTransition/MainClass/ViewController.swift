//
//  ViewController.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/22.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class ViewController: UITableViewController,UIGestureRecognizerDelegate {
    let dataArray = ["Captain.jpg","IronMan.jpg","Hulk.jpg","SpiderMan.jpg","Thor.jpg"]

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        NightNight.theme = .normal
        
        view.configNightStylePanGestureRecognizer()
        
    }
    
    //MARK: - action
    @objc func toggleNightTheme() {
        NightNight.toggleNightTheme()
    }
    

    //MARK: - UI
    func configUI() {
        self.title = "NightStyleTransition";
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        navigationController?.navigationBar.mixedTintColor = MixedColor(normal: #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1), night: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(toggleNightTheme))
        
        navigationController?.navigationBar.mixedBarStyle = MixedBarStyle(normal: .default, night: .black)
        view.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        tableView.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        tableView.mixedSeparatorColor = MixedColor(normal: #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1), night: #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1))
        tableView.tableFooterView = UIView()
        
        self.navigationItem.backBarButtonItem =  UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = UIImage(named: dataArray[indexPath.row])
        cell.textLabel?.text = "双指下滑夜间模式 双指上滑日间模式"
        cell.textLabel?.font = UIFont.init(name: "PingFangSC-Ultralight", size: 12)
        cell.mixedBackgroundColor = MixedColor(normal: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), night: #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1))
        cell.textLabel?.mixedTextColor = MixedColor(normal: .black, night: .white)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(NextViewController(), animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

