//
//  UIGestureRecognizer+X.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/23.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

public typealias X_GestureHandler = (_ gesture:UIGestureRecognizer,_ state:UIGestureRecognizerState,_ point:CGPoint ) -> ()

public extension UIGestureRecognizer{
    fileprivate struct AssociatedKeys{
        static var KGestureRecognizerBlockKey = "KGestureRecognizerBlockKey"
    }
    
    public var x_hander: X_GestureHandler {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.KGestureRecognizerBlockKey) as! X_GestureHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.KGestureRecognizerBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public convenience init(handler:@escaping X_GestureHandler){
        self.init()
        self.x_hander = handler
        self.addTarget(self, action: #selector(handleAction(gesture:)))
    }
    
    @objc private func handleAction(gesture:UIGestureRecognizer) {
        let location = self.location(in: self.view)
        gesture.x_hander(self,self.state,location)
    }
}


