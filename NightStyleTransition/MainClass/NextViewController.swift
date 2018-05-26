//
//  NextViewController.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/23.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class NextViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let dataArray = ["Captain.jpg","IronMan.jpg","Hulk.jpg","SpiderMan.jpg","Thor.jpg"]
    var tableView : UITableView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        
        tableView?.configNightStylePanGestureRecognizer()
    }
    

    func configUI() {
        title = "NextViewController"

        navigationController?.navigationBar.mixedBarStyle = MixedBarStyle(normal: .default, night: .black)
        view.mixedBackgroundColor = MixedColor(normal: #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1), night: #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1))
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView?.delegate = self
        tableView?.dataSource = self
        view.addSubview(tableView!)
        tableView?.mixedBackgroundColor = MixedColor(normal: #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1), night: #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1))
        tableView?.mixedSeparatorColor = MixedColor(normal: #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1), night: #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1))
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = UIImage(named: dataArray[indexPath.section])
        cell.textLabel?.text = "此生无悔入漫威"
        print(UIFont.familyNames)
        cell.textLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 17)
        cell.mixedBackgroundColor = MixedColor(normal: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), night: #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1))
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
