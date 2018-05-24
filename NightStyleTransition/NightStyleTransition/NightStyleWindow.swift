//
//  NightStyleWindow.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/24.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class NightStyleWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("window hitTest")
//        print("\(String(describing: event))")
        return super.hitTest(point, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("window touchesBegan")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("window gestureRecognizerShouldBegin")
        return true
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
