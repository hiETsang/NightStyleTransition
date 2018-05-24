//
//  UIView+NightStyleTransition.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/23.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

public extension UIView{
    fileprivate struct AssociatedKeys{
        static var KPreviousStyleViewSnapshotKey = "KPreviousStyleViewSnapshotKey"
        static var KSnapshotMaskLayerKey = "KSnapshotMaskLayerKey"
        static var KIsMovingDown = "KIsMovingDown"
    }
    
    private var previousStyleViewSnapshot: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.KPreviousStyleViewSnapshotKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.KPreviousStyleViewSnapshotKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var snapshotMaskLayer: CAShapeLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.KSnapshotMaskLayerKey) as? CAShapeLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.KSnapshotMaskLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var isMovingDown: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.KIsMovingDown) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.KIsMovingDown, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    //MARK: - Gesture
    public func configNightStylePanGestureRecognizer() {
        
        let panRecognizer = UIPanGestureRecognizer { (panGesture, state, point) in
            switch state {
            case .began:
                self.beginInteractiveStyleTransition(withPanRecognizer: panGesture as! UIPanGestureRecognizer)
            case .changed:
                self.adjustMaskLayer(basedOn: panGesture as! UIPanGestureRecognizer)
            case .ended, .failed:
                self.endInteractiveStyleTransition(withPanRecognizer: panGesture as! UIPanGestureRecognizer)
            default: break
            }
        }
        panRecognizer.maximumNumberOfTouches = 2
        panRecognizer.minimumNumberOfTouches = 2
        self.addGestureRecognizer(panRecognizer)
    }
    
    //MARK: - Transition
    //开始手势
    func beginInteractiveStyleTransition(withPanRecognizer panRecognizer: UIPanGestureRecognizer) {
        let window = self.window ?? self
        
        //对当前页面进行截图并且移到最上
        previousStyleViewSnapshot = window.snapshotView(afterScreenUpdates: false)
        window.addSubview(previousStyleViewSnapshot!)
        window.bringSubview(toFront: previousStyleViewSnapshot!)
        
        //创建mask layer 用于动画覆盖的效果
        snapshotMaskLayer = CAShapeLayer()
        snapshotMaskLayer?.path = UIBezierPath(rect: window.bounds).cgPath
        snapshotMaskLayer?.fillColor = UIColor.black.cgColor
        previousStyleViewSnapshot?.layer.mask = snapshotMaskLayer
        
        //底层的页面切换到新的风格
        NightNight.toggleNightTheme()
        
        //判断上滑还是下滑
        let translation = panRecognizer.translation(in: window)
        isMovingDown = translation.y > 0.0
        
        //对遮罩层进行第一次调整
        adjustMaskLayer(basedOn: panRecognizer)
    }
    
    fileprivate func adjustMaskLayer(basedOn panRecognizer: UIPanGestureRecognizer) {
        adjustMaskLayerPosition(basedOn: panRecognizer)
        adjustMaskLayerPath(basedOn: panRecognizer)
    }
    
    //调整layer的位置
    fileprivate func adjustMaskLayerPosition(basedOn panRecognizer: UIPanGestureRecognizer) {
        let window = self.window ?? self
        
        //禁用隐式动画
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let verticalTranslation = panRecognizer.translation(in: window).y
        if (isMovingDown == true) {
            if verticalTranslation < 0.0 {
                snapshotMaskLayer?.frame.origin.y = 0.0
                panRecognizer.setTranslation(.zero, in: window)
            } else {
                snapshotMaskLayer?.frame.origin.y = verticalTranslation
            }
        }else
        {
            if verticalTranslation < 0.0 {
                snapshotMaskLayer?.frame.origin.y = verticalTranslation
            } else {
                snapshotMaskLayer?.frame.origin.y = 0.0
                panRecognizer.setTranslation(.zero, in: window)
            }
        }
        
        CATransaction.commit()
    }
    
    //调整layer的曲线弧度
    fileprivate func adjustMaskLayerPath(basedOn panRecognizer: UIPanGestureRecognizer) {
        let window = self.window ?? self
        
        let maskingPath = UIBezierPath()
        
        if (isMovingDown == true) {
            //移动到原点
            maskingPath.move(to: .zero)
            
            //弹性效果设置，如果要增加弹性效果，减小阻尼值
            let damping: CGFloat = 35.0
            //速度/阻尼
            let verticalOffset = panRecognizer.velocity(in: window).y / damping
            
            maskingPath.addQuadCurve(to: CGPoint(x: window.bounds.maxX, y: 0.0), controlPoint: CGPoint(x: window.bounds.midX, y: verticalOffset))
            
            // 最下面的线
            maskingPath.addLine(to: CGPoint(x: window.bounds.maxX, y: window.bounds.maxY))
            // 左边的线
            maskingPath.addLine(to: CGPoint(x: 0.0, y: window.bounds.maxY))
            // 闭合曲线
            maskingPath.close()
        } else {
            //移动到左下点
            maskingPath.move(to: CGPoint(x: 0.0, y: window.bounds.height))
            
            //弹性效果设置，如果要增加弹性效果，减小阻尼值
            let damping: CGFloat = 35.0
            //速度/阻尼
            let verticalOffset = panRecognizer.velocity(in: window).y / damping
            
            maskingPath.addQuadCurve(to: CGPoint(x: window.bounds.maxX, y: window.bounds.height), controlPoint: CGPoint(x: window.bounds.midX, y: window.bounds.height + verticalOffset))
            
            // 右边的线
            maskingPath.addLine(to: CGPoint(x: window.bounds.maxX, y: 0.0))
            // 最上面的线
            maskingPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
            
            // 闭合曲线
            maskingPath.close()
        }
        snapshotMaskLayer?.path = maskingPath.cgPath
    }
    
    fileprivate func endInteractiveStyleTransition(withPanRecognizer panRecognizer: UIPanGestureRecognizer) {
        let window = self.window ?? self
        guard let snapshotMaskLayer = snapshotMaskLayer else {
            return
        }
        
        let velocity = panRecognizer.velocity(in: window)
        
        var targetLocation:CGPoint!
        
        if (velocity.y > 0.0) {
            targetLocation = isMovingDown! ? CGPoint(x: 0.0, y: window.bounds.maxY) : .zero
            animate(snapshotMaskLayer, to: targetLocation, withVelocity: velocity) {
                if self.isMovingDown == false {
                    NightNight.toggleNightTheme()
                }
                
                self.cleanupAfterInteractiveStyleTransition()
            }
        } else {
            targetLocation = isMovingDown! ? .zero : CGPoint(x: 0.0, y: -window.bounds.maxY)
            animate(snapshotMaskLayer, to: targetLocation, withVelocity: velocity) {
                if self.isMovingDown == true {
                    NightNight.toggleNightTheme()
                }
                
                self.cleanupAfterInteractiveStyleTransition()
            }
        }
        
        //
        //        if velocity.y > 0.0 {
        //            movingDownInteractiveStyleTransition(withVelocity: velocity)
        //        } else {
        //            movingUpInteractiveStyleTransition(withVelocity: velocity)
        //        }
    }
    
//    fileprivate func movingUpInteractiveStyleTransition(withVelocity velocity: CGPoint) {
//        guard let snapshotMaskLayer = snapshotMaskLayer else {
//            return
//        }
//
//        if (isMovingDown == true) {
//            //下滑的状态的话，最后手势往上需要取消
//
//        }else
//        {
//            animate(snapshotMaskLayer, to: .zero, withVelocity: velocity) {
//                NightNight.toggleNightTheme()
//                self.cleanupAfterInteractiveStyleTransition()
//            }
//        }
//
//
//    }
//
//    fileprivate func movingDownInteractiveStyleTransition(withVelocity velocity: CGPoint) {
//        guard let window = self.window, let snapshotMaskLayer = snapshotMaskLayer else {
//            return
//        }
//
//
//
//        let targetLocation = CGPoint(x: 0.0, y: window.bounds.maxY)
//        animate(snapshotMaskLayer, to: targetLocation, withVelocity: velocity) {
//            self.cleanupAfterInteractiveStyleTransition()
//        }
//    }
    
    fileprivate func cleanupAfterInteractiveStyleTransition() {
        self.previousStyleViewSnapshot?.removeFromSuperview()
        self.previousStyleViewSnapshot = nil
        self.snapshotMaskLayer = nil
    }
    
    // MARK: - Animation
    fileprivate func timeRequiredToMove(from: CGPoint, to: CGPoint, withVelocity velocity: CGPoint) -> TimeInterval {
        let distanceToMove = sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
        let velocityMagnitude = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
        let requiredTime = TimeInterval(abs(distanceToMove / velocityMagnitude))
        return requiredTime
    }
    
    fileprivate func animate(_ layer: CALayer, to targetPoint: CGPoint, withVelocity velocity: CGPoint, completion: @escaping () -> Void) {
        let startPoint = layer.position
        layer.position = targetPoint
        
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.duration = min(0.4, timeRequiredToMove(from: startPoint, to: targetPoint, withVelocity: velocity))
        positionAnimation.fromValue = NSValue(cgPoint: startPoint)
        positionAnimation.toValue = NSValue(cgPoint: targetPoint)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        layer.add(positionAnimation, forKey: "position")
        
        CATransaction.commit()
    }
    
}


