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
