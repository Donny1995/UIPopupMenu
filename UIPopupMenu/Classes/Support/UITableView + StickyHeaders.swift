//
//  UITableView + StickyHeaders.swift
//  UIComponents
//
//  Created by Sivash Alexander Alexeevich on 13.12.2021.
//

import Foundation
import UIKit

extension UITableView {
    
    var allowsHeaderViewsToFloat: Bool {
        get {
            return getTableViewState().allowsHeaderViewsToFloat
        }
        set {
            Self.swizzleControlsIfNeeded()
            let state = getTableViewState()
            state.allowsHeaderViewsToFloat = newValue
            objc_setAssociatedObject(self, &Self.kTableViewStateAssociationKey, state, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var allowsFooterViewsToFloat: Bool {
        get {
            return getTableViewState().allowsFooterViewsToFloat
        }
        set {
            Self.swizzleControlsIfNeeded()
            let state = getTableViewState()
            state.allowsFooterViewsToFloat = newValue
            objc_setAssociatedObject(self, &Self.kTableViewStateAssociationKey, state, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate static var didApplyHooks: Bool = false
    fileprivate static var kTableViewStateAssociationKey: String = "getPopupTableViewState"
    fileprivate func getTableViewState() -> UITableViewAssociatedValues {
        return objc_getAssociatedObject(self, &Self.kTableViewStateAssociationKey) as? UITableViewAssociatedValues ?? UITableViewAssociatedValues()
    }
    
    fileprivate static func swizzleControlsIfNeeded() {
        guard !didApplyHooks else { return }
        didApplyHooks = true
        
        //- (BOOL)allowsHeaderViewsToFloat;
        let fromHSelector = Selector(stringLiteral: "allowsHeaderViewsToFloat")
        let toHSelector = #selector(internal_c_allowsHeaderViewsToFloat)
        if let originalMethod = class_getInstanceMethod(UITableView.self, fromHSelector), let swappedMethod = class_getInstanceMethod(UITableView.self, toHSelector) {
            let didAddMethod = class_addMethod(UITableView.self, fromHSelector, method_getImplementation(swappedMethod), method_getTypeEncoding(swappedMethod))
            if didAddMethod {
                class_replaceMethod(UITableView.self, toHSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swappedMethod)
            }
        } else {
            didApplyHooks = false
        }
        
        //- (BOOL)allowsFooterViewsToFloat;
        let fromFSelector = Selector(stringLiteral: "allowsFooterViewsToFloat")
        let toFSelector = #selector(internal_c_allowsFooterViewsToFloat)
        if let originalMethod = class_getInstanceMethod(UITableView.self, fromFSelector), let swappedMethod = class_getInstanceMethod(UITableView.self, toFSelector) {
            let didAddMethod = class_addMethod(UITableView.self, fromFSelector, method_getImplementation(swappedMethod), method_getTypeEncoding(swappedMethod))
            if didAddMethod {
                class_replaceMethod(UITableView.self, toFSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swappedMethod)
            }
        } else {
            didApplyHooks = false
        }
    }
    
    @objc dynamic func internal_c_allowsHeaderViewsToFloat() -> Bool {
        if getTableViewState().allowsHeaderViewsToFloat {
            return self.internal_c_allowsHeaderViewsToFloat()
        } else {
            return false
        }
    }
    
    @objc dynamic func internal_c_allowsFooterViewsToFloat() -> Bool {
        if getTableViewState().allowsFooterViewsToFloat {
            return self.internal_c_allowsFooterViewsToFloat()
        } else {
            return false
        }
    }
}

fileprivate class UITableViewAssociatedValues {
    var allowsHeaderViewsToFloat: Bool = true
    var allowsFooterViewsToFloat: Bool = true
}
