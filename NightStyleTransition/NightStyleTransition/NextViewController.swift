//
//  NextViewController.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/23.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class NextViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView : TestTableView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    func configUI() {
        title = "NextViewController"
        
        navigationController?.navigationBar.mixedBarStyle = MixedBarStyle(normal: .default, night: .black)
        view.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        
        tableView = TestTableView(frame: view.bounds, style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        view.addSubview(tableView!)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
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
