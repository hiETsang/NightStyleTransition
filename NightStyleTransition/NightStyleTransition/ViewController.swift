//
//  ViewController.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/22.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class ViewController: UITableViewController,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        NightNight.theme = .normal
        
//        view.configNightStylePanGestureRecognizer()
        
    }
    
    //MARK: - action
    @objc func toggleNightTheme() {
        NightNight.toggleNightTheme()
    }
    

    //MARK: - UI
    func configUI() {
        self.title = "NightStyleTransition";
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(toggleNightTheme))
        
        navigationController?.navigationBar.mixedBarStyle = MixedBarStyle(normal: .default, night: .black)
        view.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        tableView.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = UIImage(named: "appodden")
        cell.textLabel?.text = "双指下滑夜间模式，双指上滑日间模式"
        cell.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
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

