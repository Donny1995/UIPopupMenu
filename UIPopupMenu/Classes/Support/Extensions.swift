//
//  Extensions.swift
//  UIPopupMenu
//
//  Created by Alexandr Sivash on 27.02.2023.
//

import UIKit

extension UIView {
    var viewController: UIViewController? {
        if let simple = parentFocusEnvironment as? UIViewController {
            return simple
        } else {
            
            var last = parentFocusEnvironment
            
            while let next = last?.parentFocusEnvironment {
                if let controller = next as? UIViewController {
                    return controller
                }
                last = next
            }
        }
        return nil
    }
}

extension NSLayoutConstraint {
    @discardableResult func priority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
    @discardableResult func priority(_ priority: CGFloat) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(min(max(0, Float(priority)), UILayoutPriority.required.rawValue))
        return self
    }
    
    @discardableResult func name(_ name: String) -> NSLayoutConstraint {
        identifier = name
        return self
    }
    
    @discardableResult func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }
    
    @discardableResult func deactivate() -> NSLayoutConstraint {
        isActive = false
        return self
    }
}

extension UIView {
    
    /**
     * Disable Implicit animation
     * EXAMPLE: disableAnim{view.layer?.position = 20}//Default animation is now disabled
     */
    static func performWithoutAnyAnimationAtAll(_ block:() -> Void ) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }
    
    func fadeTransitionAnimation(duration: TimeInterval) {
        fadeTransitionAnimation(duration: duration, block: { })
    }
    
    func fadeTransitionAnimation(duration: TimeInterval, block: () -> Void) {
        let a = CATransition()
        a.type = .fade
        a.fillMode = .forwards
        a.duration = duration
        block()
        layer.add(a, forKey: "fadeTransitionAnimation")
    }
}

extension UIViewController {
    
    ///Поднимается на самый верх по иерархии вью контроллеров
    var rootController: UIViewController {
        if let rootFromScene = view.window?.windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            return rootFromScene
            
        } else if let rootOfCurrentWindow = view.window?.rootViewController {
            return rootOfCurrentWindow
            
        } else {
            return self
        }
    }
    
    ///Поднимается на самый верх по иерархии вью контроллеров, а потом спускается в самый низ по цепочке презентов.
    ///Это сделано для того, чтобы всегда можно было найти какой-то презенто-способный контроллер для какого-нибудь алерта.
    var topPresentableViewController: UIViewController {
        var current = rootController
        while let ctr = current.presentedViewController, !ctr.isBeingDismissed {
            current = ctr
        }
        
        return current
    }
}

extension UIView {
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

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

extension CGFloat {
    func clamped(min _minimum: Self, max _maximum: Self) -> Self {
        return CGFloat.maximum(CGFloat.minimum(_maximum, self), _minimum)
    }
}
