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
            case .ended, .failed:break
//                self.endInteractiveStyleTransition(withPanRecognizer: panGesture as! UIPanGestureRecognizer)
            default: break
            }
        }
        panRecognizer.maximumNumberOfTouches = 2
        panRecognizer.minimumNumberOfTouches = 2
        self.addGestureRecognizer(panRecognizer)
    }
    
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
//            return true
//        }
//
//        let translation = panRecognizer.translation(in: tableView.window)
//        let isMovingDownwards = translation.y > 0.0
//        return isMovingDownwards
//    }
    
    //MARK: - Transition
    //开始手势
    func beginInteractiveStyleTransition(withPanRecognizer panRecognizer: UIPanGestureRecognizer) {
        guard let window = self.window else {
            return
        }
        
        //对当前页面进行截图并且移到最上
        previousStyleViewSnapshot = window.snapshotView(afterScreenUpdates: false)
        window.addSubview(previousStyleViewSnapshot!)
        window.bringSubview(toFront: previousStyleViewSnapshot!)
        
        //创建mask layer 用于动画覆盖的效果
        snapshotMaskLayer = CAShapeLayer()
        snapshotMaskLayer?.path = UIBezierPath(rect: window.bounds).cgPath
        snapshotMaskLayer?.fillColor = UIColor.black.cgColor
        previousStyleViewSnapshot?.layer.mask = snapshotMaskLayer
        
        //切换到新的风格
        NightNight.toggleNightTheme()
        
        //判断上滑还是下滑
        let translation = panRecognizer.translation(in: self.window)
        isMovingDown = translation.y > 0.0
        
        //对遮罩层进行第一次调整
        adjustMaskLayer(basedOn: panRecognizer)
    }
    
    fileprivate func adjustMaskLayer(basedOn panRecognizer: UIPanGestureRecognizer) {
        adjustMaskLayerPosition(basedOn: panRecognizer)
//        adjustMaskLayerPath(basedOn: panRecognizer)
    }
    
    //调整layer的位置
    fileprivate func adjustMaskLayerPosition(basedOn panRecognizer: UIPanGestureRecognizer) {
        guard let window = self.window else {
            return
        }
        
        //禁用隐式动画
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let verticalTranslation = panRecognizer.translation(in: window).y
        print("verticalTranslation is \(verticalTranslation)")

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
                snapshotMaskLayer?.frame.size.height = (self.window?.bounds.height)! + verticalTranslation
            } else {
                snapshotMaskLayer?.frame.size.height = (self.window?.bounds.height)!
            }
            print("snapshotMaskLayer.h is \(String(describing: snapshotMaskLayer?.frame.size.height))")

        }
        
        
        CATransaction.commit()
    }
    
    //调整layer的曲线弧度
    fileprivate func adjustMaskLayerPath(basedOn panRecognizer: UIPanGestureRecognizer) {
        guard let window = self.window else {
            return
        }
        
        let maskingPath = UIBezierPath()
        
        // Top-left corner...
        maskingPath.move(to: .zero)
        
        // ...arc to top-right corner...
        // This is all the code that is required to get the bouncy effect.
        // Since the control point of the quad curve depends on the velocity
        // of the pan recognizer, the path will "deform" more for a larger
        // velocity.
        // We don't need to do anything to animate the path back to its
        // non-deformed state since the pan gesture recognizer's target method
        // (panRecognizerDidChange(_:) in our case) is called periodically
        // even when the user stops moving their finger (until the velocity
        // reaches 0).
        // Note: To increase the bouncy effect, decrease the `damping` value.
        let damping: CGFloat = 45.0
        let verticalOffset = panRecognizer.velocity(in: window).y / damping
        maskingPath.addQuadCurve(to: CGPoint(x: window.bounds.maxX, y: 0.0), controlPoint: CGPoint(x: window.bounds.midX, y: verticalOffset))
        
        // ...to bottom-right corner...
        maskingPath.addLine(to: CGPoint(x: window.bounds.maxX, y: window.bounds.maxY))
        
        // ...to bottom-left corner...
        maskingPath.addLine(to: CGPoint(x: 0.0, y: window.bounds.maxY))
        
        // ...and close the path.
        maskingPath.close()
        
        snapshotMaskLayer?.path = maskingPath.cgPath
    }
    
    fileprivate func endInteractiveStyleTransition(withPanRecognizer panRecognizer: UIPanGestureRecognizer) {
        guard let window = self.window else {
            return
        }
        
        let velocity = panRecognizer.velocity(in: window)
        let translation = panRecognizer.translation(in: window)
        
        let isMovingDownwards = velocity.y > 0.0
        let hasPassedThreshold = translation.y > window.bounds.midY
        
        // We support both completing the transition and cancelling the transition.
        // The transition to the new style should be completed if the user is panning
        // downwards or if they've panned enough that more than half of the new view
        // is already shown.
        let shouldCompleteTransition = isMovingDownwards || hasPassedThreshold
        
        if shouldCompleteTransition {
            completeInteractiveStyleTransition(withVelocity: velocity)
        } else {
            cancelInteractiveStyleTransition(withVelocity: velocity)
        }
    }
    
    fileprivate func cancelInteractiveStyleTransition(withVelocity velocity: CGPoint) {
        guard let snapshotMaskLayer = snapshotMaskLayer else {
            return
        }
        
        // When cancelling the transition we simply move the mask layer to it's original
        // location (which means that the entire previous style snapshot is shown), then
        // reset the style to the previous style and remove the snapshot.
        animate(snapshotMaskLayer, to: .zero, withVelocity: velocity) {
            NightNight.toggleNightTheme()
            self.cleanupAfterInteractiveStyleTransition()
        }
    }
    
    fileprivate func completeInteractiveStyleTransition(withVelocity velocity: CGPoint) {
        guard let window = self.window, let snapshotMaskLayer = snapshotMaskLayer else {
            return
        }
        
        
        // When completing the transition we slide the mask layer down to the bottom of
        // the window and then remove the snapshot. The further down the mask layer is,
        // the more of the underlying view is visible. When the mask layer reaches the
        // bottom of the window, the entire underlying view will be visible so removing
        // the snapshot will have no visual effect.
        let targetLocation = CGPoint(x: 0.0, y: window.bounds.maxY)
        animate(snapshotMaskLayer, to: targetLocation, withVelocity: velocity) {
            self.cleanupAfterInteractiveStyleTransition()
        }
    }
    
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
        positionAnimation.duration = min(1.0, timeRequiredToMove(from: startPoint, to: targetPoint, withVelocity: velocity))
        positionAnimation.fromValue = NSValue(cgPoint: startPoint)
        positionAnimation.toValue = NSValue(cgPoint: targetPoint)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        layer.add(positionAnimation, forKey: "position")
        
        CATransaction.commit()
    }
    
}


