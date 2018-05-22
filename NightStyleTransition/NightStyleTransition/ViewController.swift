//
//  ViewController.swift
//  NightStyleTransition
//
//  Created by canoe on 2018/5/22.
//  Copyright © 2018年 canoe. All rights reserved.
//

import UIKit

class ViewController: UITableViewController,UIGestureRecognizerDelegate {
    
    var previousStyleViewSnapshot: UIView?

    var snapshotMaskLayer: CAShapeLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        NightNight.theme = .night
        
        configPanGestureRecognizer()
    }
    
    
    //MARK: - UI
    func configUI() {
        self.title = "NightStyleTransition";
        
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(toggleNightTheme))
        
        navigationController?.navigationBar.mixedBarStyle = MixedBarStyle(normal: .default, night: .black)
        view.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
        tableView.mixedBackgroundColor = MixedColor(normal: .white, night: .black)
    }
    
    @objc func toggleNightTheme() {
        NightNight.toggleNightTheme()
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
    
    
    //MARK: - Gesture
    fileprivate func configPanGestureRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panRecognizerDidChange(_:)))
        panRecognizer.maximumNumberOfTouches = 2
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.delegate = self
        tableView.addGestureRecognizer(panRecognizer)
    }
    
    @objc func panRecognizerDidChange(_ panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            beginInteractiveStyleTransition(withPanRecognizer: panRecognizer)
        case .changed:
            adjustMaskLayer(basedOn: panRecognizer)
        case .ended, .failed:
            endInteractiveStyleTransition(withPanRecognizer: panRecognizer)
        default: break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        let translation = panRecognizer.translation(in: tableView.window)
        let isMovingDownwards = translation.y > 0.0
        return isMovingDownwards
    }
    
    //MARK: - Transition
    //开始动画
    func beginInteractiveStyleTransition(withPanRecognizer panRecognizer: UIPanGestureRecognizer) {
        guard let window = tableView.window else {
            return
        }
        
        // We snapshot the window before applying the new style, and make sure
        // it's positioned on top of all the other content.
        previousStyleViewSnapshot = window.snapshotView(afterScreenUpdates: false)
        window.addSubview(previousStyleViewSnapshot!)
        window.bringSubview(toFront: previousStyleViewSnapshot!)
        
        // When we have the snapshot we create a new mask layer that's used to
        // control how much of the previous view we display as the transition
        // progresses.
        snapshotMaskLayer = CAShapeLayer()
        snapshotMaskLayer?.path = UIBezierPath(rect: window.bounds).cgPath
        snapshotMaskLayer?.fillColor = UIColor.black.cgColor
        previousStyleViewSnapshot?.layer.mask = snapshotMaskLayer
        
        // Now we're free to apply the new style. This won't be visible until
        // the user pans more since the snapshot is displayed on top of the
        // actual content.

        NightNight.toggleNightTheme()
        
        // Finally we make our first adjustment to the mask layer based on the
        // values of the pan recognizer.
        adjustMaskLayer(basedOn: panRecognizer)
    }
    
    fileprivate func adjustMaskLayer(basedOn panRecognizer: UIPanGestureRecognizer) {
        adjustMaskLayerPosition(basedOn: panRecognizer)
        adjustMaskLayerPath(basedOn: panRecognizer)
    }
    
    fileprivate func adjustMaskLayerPosition(basedOn panRecognizer: UIPanGestureRecognizer) {
        guard let window = tableView.window else {
            return
        }
        
        // We need to disable implicit animations since we don't want to
        // animate the position change of the mask layer.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let verticalTranslation = panRecognizer.translation(in: window).y
        if verticalTranslation < 0.0 {
            // We wan't to prevent the user from moving the mask layer out the
            // top of the window, since doing so would show the new style at
            // the bottom of the window instead.
            // By resetting the translation we make sure there's no visual
            // delay between when the user tries to pan upwards and when they
            // start panning downwards again.
            panRecognizer.setTranslation(.zero, in: window)
            snapshotMaskLayer?.frame.origin.y = 0.0
        } else {
            // Simply move the mask layer as much as the user has panned.
            // Note that if we had used the _location_ of the pan recognizer
            // instead of the translation, the top of the mask layer would
            // follow the fingers exactly. Using the translation results in a
            // better user experience since the location of the mask layer is
            // instead relative to the distance moved.
            snapshotMaskLayer?.frame.origin.y = verticalTranslation
        }
        
        CATransaction.commit()
    }
    
    fileprivate func adjustMaskLayerPath(basedOn panRecognizer: UIPanGestureRecognizer) {
        guard let window = tableView.window else {
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
        guard let window = tableView.window else {
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
        guard let window = tableView.window, let snapshotMaskLayer = snapshotMaskLayer else {
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
    
    

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

