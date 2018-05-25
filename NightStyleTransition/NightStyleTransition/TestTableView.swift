//
//  TestTableView.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/24.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class TestTableView: UITableView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tableView touchesBegan")
        super.touchesBegan(touches, with: event)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("tableView gestureRecognizerShouldBegin")
        if gestureRecognizer.numberOfTouches == 2 {
            return false
        }
        return true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("tableView hitTest")
        return super.hitTest(point, with: event)
    }

}
