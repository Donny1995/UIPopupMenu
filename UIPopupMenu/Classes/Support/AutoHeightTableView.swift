//
//  AutoHeightTableView.swift
//  UIPopupMenu
//
//  Created by Alexandr Sivash on 27.02.2023.
//

import Foundation
import UIKit

class AutoHeightTableView: UITableView {
    
    var contentSizeObserver: NSObjectProtocol?
    var heightObserver: NSObjectProtocol?
    
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        contentSizeObserver = observe(\.contentSize, options: [.new]) { (table, value) in
            var calculatedSize = value.newValue ?? table.contentSize
            calculatedSize.height += table.contentInset.top + table.contentInset.bottom
            
            if let header = table.tableHeaderView {
                calculatedSize.height += header.frame.height
            }
            
            if let footer = table.tableFooterView {
                calculatedSize.height += footer.frame.height
            }
            
            calculatedSize.height = min(calculatedSize.height, table.maxHeight)
            
            table.cachedContentHeight = round(calculatedSize.height)
        }
        
        heightObserver = observe(\.bounds, options: .new) { (table, value) in
            let calculatedHeight = value.newValue?.height ?? table.frame.height
            table.cachedFrameHeight = calculatedHeight
        }
    }
    
    public var isScrollDisabledWhenHeightIsSufficient: Bool = false {
        didSet {
            guard isScrollDisabledWhenHeightIsSufficient != oldValue else { return }
            recalculateIsScrollFlag()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc dynamic var cachedContentHeight: CGFloat = 0.0 {
        didSet {
            guard oldValue != cachedContentHeight else { return }
            recalculateIsScrollFlag()
            invalidateIntrinsicContentSize()
        }
    }
    
    var cachedFrameHeight: CGFloat = 0.0 {
        didSet {
            guard oldValue != cachedFrameHeight else { return }
            recalculateIsScrollFlag()
        }
    }
    
    public var maxHeight: CGFloat = UIScreen.main.bounds.size.height {
        didSet {
            guard oldValue != maxHeight else { return }
            invalidateIntrinsicContentSize()
        }
    }
  
    override open func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
    
    open override func endUpdates() {
        super.endUpdates()
        invalidateIntrinsicContentSize()
    }
    
    open override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        super.performBatchUpdates(updates, completion: completion)
    }
    
    @discardableResult
    func recalculateIsScrollFlag() -> Bool {
        let isHeightSufficient = cachedFrameHeight > cachedContentHeight || abs(cachedFrameHeight - cachedContentHeight) <= 1/UIScreen.main.scale
        let shouldNotBounce = isScrollDisabledWhenHeightIsSufficient && isHeightSufficient
        
        if bounces == shouldNotBounce {
            bounces = !shouldNotBounce
        }
        
        return bounces
    }
    
    open override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
    }
  
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: cachedContentHeight)
    }
}
