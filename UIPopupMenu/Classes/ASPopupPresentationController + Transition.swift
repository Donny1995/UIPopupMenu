//
//  ASPopupPresentationController + Transition.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 22.02.2023.
//

import Foundation
import UIKit

extension ASPopupPresentationController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let toViewController = presented as? ASPopupPresentationController {
            return ASPopupPresentationController.PresentAnimator(controller: toViewController)
        }
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let toViewController = dismissed as? ASPopupPresentationController {
            return ASPopupPresentationController.DismissAnimator(controller: toViewController)
        }
        
        return nil
    }
}

extension ASPopupPresentationController {
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        weak var popupViewController: ASPopupPresentationController?
        init(controller: ASPopupPresentationController) {
            self.popupViewController = controller
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.45
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let toViewController = popupViewController, popupViewController == transitionContext.viewController(forKey: .to) else {
                return
            }
            
            let containerView = transitionContext.containerView
            let wasAutoresizing = toViewController.view.autoresizesSubviews
            toViewController.containerView.alpha = 0.0
            
            containerView.addSubview(toViewController.view)
            
            let params = toViewController.calculateContainerViewFrame()
            let goesBelow = toViewController.positionContentViewIfNeeded(params: params) ?? true
            toViewController.view.layoutIfNeeded()
            toViewController.containerView.layoutSubviews()
            toViewController.view.autoresizesSubviews = false
            
            let yOriginShift: CGFloat = goesBelow ? 0.0 : 1.0
            var xOriginShift: CGFloat = 0.5
            var yOriginShiftOffset: CGFloat = 0.0
            
            if let originView = toViewController.originView,
               let containerFrameInWindowCoords = toViewController.containerView.globalFrame,
               let originViewFrameInWindowCoords = originView.globalFrame
            {
                let containerCenterInWindowCoords = containerFrameInWindowCoords.center.x
                let originViewCenterInWindowCoords = originViewFrameInWindowCoords.center.x
                let criteria = (containerCenterInWindowCoords - originViewCenterInWindowCoords)/toViewController.containerView.bounds.width
                xOriginShift -= max(-0.5, min(0.5, criteria))
                
                if originViewFrameInWindowCoords.intersects(containerFrameInWindowCoords) {
                    if goesBelow {
                        yOriginShiftOffset = (originViewFrameInWindowCoords.center.y - containerFrameInWindowCoords.origin.y) / containerFrameInWindowCoords.size.height
                        
                    } else {
                        yOriginShiftOffset = -(containerFrameInWindowCoords.maxY - originViewFrameInWindowCoords.center.y) / containerFrameInWindowCoords.size.height
                    }
                }
            }
            
            let duration = transitionDuration(using: transitionContext)
            let originalHeight = toViewController.containerView.bounds.size.height
            
            toViewController.containerView.shiftAnchorPoint(to: .init(x: xOriginShift, y: yOriginShift + yOriginShiftOffset))
            toViewController.containerView.transform = .init(scaleX: 0.1, y: 0.1)
            toViewController.containerView.bounds.size.height *= 0.2
            toViewController.view.autoresizesSubviews = false
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.allowAnimatedContent]) {
                toViewController.containerView.alpha = 1.0
                toViewController.containerView.transform = .identity
                toViewController.containerView.bounds.size.height = originalHeight
                
            } completion: { _ in
                toViewController.containerView.shiftAnchorPoint(to: .init(x: 0.5, y: 0.5))
                toViewController.view.autoresizesSubviews = wasAutoresizing
                transitionContext.completeTransition(true)
            }
        }
    }
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        weak var popupViewController: ASPopupPresentationController?
        init(controller: ASPopupPresentationController) {
            self.popupViewController = controller
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.3
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromViewController = popupViewController, popupViewController == transitionContext.viewController(forKey: .from) else {
                return
            }
            
            let wasAutoresizing = fromViewController.view.autoresizesSubviews
            let goesBelow = fromViewController.calculateContainerViewFrame()?.goesDown ?? true
            
            fromViewController.view.autoresizesSubviews = false
            
            let yOriginShift: CGFloat = goesBelow ? 0.0 : 1.0
            var xOriginShift: CGFloat = 0.5
            var yOriginShiftOffset: CGFloat = 0.0
            
            if let originView = fromViewController.originView,
               let containerFrameInWindowCoords = fromViewController.containerView.globalFrame,
               let originViewFrameInWindowCoords = originView.globalFrame
            {
                let containerCenterInWindowCoords = containerFrameInWindowCoords.center.x
                let originViewCenterInWindowCoords = originViewFrameInWindowCoords.center.x
                let criteria = (containerCenterInWindowCoords - originViewCenterInWindowCoords)/fromViewController.containerView.bounds.width
                xOriginShift -= max(-0.5, min(0.5, criteria))
                
                if originViewFrameInWindowCoords.intersects(containerFrameInWindowCoords) {
                    if goesBelow {
                        yOriginShiftOffset = (originViewFrameInWindowCoords.center.y - containerFrameInWindowCoords.origin.y) / containerFrameInWindowCoords.size.height
                        
                    } else {
                        yOriginShiftOffset = -(containerFrameInWindowCoords.maxY - originViewFrameInWindowCoords.center.y) / containerFrameInWindowCoords.size.height
                    }
                }
            }
            
            fromViewController.containerView.shiftAnchorPoint(to: .init(x: xOriginShift, y: yOriginShift + yOriginShiftOffset))
            let originalHeight = fromViewController.containerView.bounds.size.height
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: []) {
                fromViewController.containerView.alpha = 0.0
                fromViewController.containerView.transform = .init(scaleX: 0.1, y: 0.1)
                fromViewController.containerView.bounds.size.height *= 0.2
                
            } completion: { _ in
                fromViewController.view.removeFromSuperview()
                fromViewController.containerView.bounds.size.height = originalHeight
                fromViewController.containerView.transform = .identity
                fromViewController.containerView.shiftAnchorPoint(to: .init(x: 0.5, y: 0.5))
                fromViewController.view.autoresizesSubviews = wasAutoresizing
                transitionContext.completeTransition(true)
            }
        }
    }
}

fileprivate extension UIView {
    var globalFrame: CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
    
    func shiftAnchorPoint(to point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = point
    }
}

fileprivate extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}
