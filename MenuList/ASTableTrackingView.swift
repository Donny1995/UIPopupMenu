//
//  ASTableTrackingView.swift
//  UIPopupMenu
//
//  Created by Alexandr Sivash on 11.04.2023.
//

import Foundation
import UIKit

open class ASTableTrackingView: UIView, ASPopupPresentationViewContentDynamicSize {
    
    public var title: String?
    open var isFlashingScrollIndicatorsOnAppear = true
    
    let autoheightTableView = AutoHeightTableView()
    public var tableView: UITableView { autoheightTableView }
    
    public func updatePreferredContentSize() {
        let newSize = CGSize(
            width: UIScreen.main.bounds.width * 0.58,
            height: max(40, self.autoheightTableView.cachedContentHeight + (headerView?.frame.height ?? 0) + (footerView?.frame.height ?? 0))
        )
        
        if lastRequestedPreferredContentSize != newSize {
            lastRequestedPreferredContentSize = newSize
            preferredContentSize = newSize
        }
    }
    
    public var preferredContentSizeDidChange: ((CGSize) -> Void)?
    public var preferredContentSize: CGSize = .zero {
        didSet {
            guard preferredContentSize != oldValue else { return }
            preferredContentSizeDidChange?(preferredContentSize)
        }
    }
    
    var tableHeightObserver: NSKeyValueObservation?
    var lastRequestedPreferredContentSize: CGSize?
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if !isViewLoaded {
            viewDidLoad()
        }
        
        if isFlashingScrollIndicatorsOnAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                if self.autoheightTableView.isScrollEnabled && self.autoheightTableView.bounces {
                    self.autoheightTableView.flashScrollIndicators()
                }
            }
        }
    }
    
    var isViewLoaded: Bool = false
    open func viewDidLoad() {
        isViewLoaded = true
        
        autoheightTableView.backgroundColor = .clear
        autoheightTableView.estimatedRowHeight = 40
        autoheightTableView.estimatedSectionHeaderHeight = 40
        autoheightTableView.rowHeight = UITableView.automaticDimension
        autoheightTableView.separatorInset = .zero
        autoheightTableView.isScrollDisabledWhenHeightIsSufficient = true
        autoheightTableView.showsVerticalScrollIndicator = true
        autoheightTableView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        if #available(iOS 15.0, *) {
            autoheightTableView.sectionHeaderTopPadding = 0
        }
        
        autoheightTableView.reloadData()
        layoutIfNeeded()
        
        tableHeightObserver = autoheightTableView.observe(\.cachedContentHeight) { [weak self] _, _ in
            self?.updatePreferredContentSize()
        }
    }
    
    private var headerViewNeedsStrongUpdate: Bool = false
    /// View, that will be added/removed above the tableview
    public weak var headerView: UIView? {
        didSet {
            guard headerView != oldValue else { return }
            headerViewNeedsStrongUpdate = true
            setNeedsUpdateConstraints()
            if let newHeader = headerView {
                newHeader.translatesAutoresizingMaskIntoConstraints = false
                addSubview(newHeader)
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    private var footerViewNeedsStrongUpdate: Bool = false
    /// View, that will be added/removed below the tableview
    public weak var footerView: UIView? {
        didSet{
            guard footerView != oldValue else { return }
            footerViewNeedsStrongUpdate = true
            setNeedsUpdateConstraints()
            if let newFooter = footerView {
                newFooter.translatesAutoresizingMaskIntoConstraints = false
                addSubview(newFooter)
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    open override func updateConstraints() {
        let tableNeedsUpdate = headerViewNeedsStrongUpdate || footerViewNeedsStrongUpdate || autoheightTableView.superview == nil
        
        //header
        if headerViewNeedsStrongUpdate {
            headerViewNeedsStrongUpdate = false
            if let headerView {
                headerView.eraseConstraints()
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: headerView.superview!.topAnchor),
                    headerView.leadingAnchor.constraint(equalTo: headerView.superview!.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: headerView.superview!.trailingAnchor),
                ])
            }
        }
        
        //table
        if autoheightTableView.superview == nil {
            autoheightTableView.frame = .init(
                origin: .init(x: 0, y: headerView?.frame.maxY ?? 0),
                size: .init(width: frame.width, height: frame.height - (headerView?.frame.height ?? 0) - (footerView?.frame.height ?? 0))
            )
            
            addSubview(autoheightTableView)
        }
        
        if tableNeedsUpdate {
            autoheightTableView.eraseConstraints()
            NSLayoutConstraint.activate([
                autoheightTableView.topAnchor.constraint(equalTo: headerView?.bottomAnchor ?? topAnchor),
                autoheightTableView.leadingAnchor.constraint(equalTo: autoheightTableView.superview!.leadingAnchor),
                autoheightTableView.trailingAnchor.constraint(equalTo: autoheightTableView.superview!.trailingAnchor),
                autoheightTableView.bottomAnchor.constraint(equalTo: footerView?.topAnchor ?? bottomAnchor),
            ])
        }
        
        //footer
        if footerViewNeedsStrongUpdate {
            footerViewNeedsStrongUpdate = false
            if let footerView {
                footerView.eraseConstraints()
                NSLayoutConstraint.activate([
                    footerView.leadingAnchor.constraint(equalTo: footerView.superview!.leadingAnchor),
                    footerView.trailingAnchor.constraint(equalTo: footerView.superview!.trailingAnchor),
                    footerView.bottomAnchor.constraint(equalTo: footerView.superview!.topAnchor),
                ])
            }
        }
        
        super.updateConstraints()
    }
}

extension UIView {
    func eraseConstraints() {
        
        //NSLayoutConstraint.deactivate(constraints)
        
        if let superview {
            for constraint in superview.constraints {
                let sself = ObjectIdentifier(self)
                
                if let firstItem = constraint.firstItem {
                    if ObjectIdentifier(firstItem) == sself {
                        constraint.isActive = false
                    }
                }
                
                if let secondItem = constraint.secondItem {
                    if ObjectIdentifier(secondItem) == sself {
                        constraint.isActive = false
                    }
                }
            }
        }
    }
}
