//
//  NextViewController.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/23.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class NextViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView : UITableView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        
        tableView?.configNightStylePanGestureRecognizer()
    }
    
    func configUI() {
        title = "NextViewController"
        
        navigationController?.navigationBar.mixedBarStyle = MixedBarStyle(normal: .default, night: .black)
        view.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        view.addSubview(tableView!)
        tableView?.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = UIImage(named: "appodden")
        cell.textLabel?.text = "双指下滑夜间模式，双指上滑日间模式"
        cell.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        cell.textLabel?.mixedTextColor = MixedColor(normal: .black, night: .white)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
