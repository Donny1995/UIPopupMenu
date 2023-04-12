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
    
    public let tableView = AutoHeightTableView()
    public func updatePreferredContentSize() {
        let newSize = CGSize(
            width: UIScreen.main.bounds.width * 0.58,
            height: max(40, self.tableView.cachedContentHeight + (headerView?.frame.height ?? 0) + (footerView?.frame.height ?? 0))
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
                if self.tableView.isScrollEnabled && self.tableView.bounces {
                    self.tableView.flashScrollIndicators()
                }
            }
        }
    }
    
    var isViewLoaded: Bool = false
    open func viewDidLoad() {
        isViewLoaded = true
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 40
        tableView.estimatedSectionHeaderHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.isScrollDisabledWhenHeightIsSufficient = true
        tableView.showsVerticalScrollIndicator = true
        tableView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.reloadData()
        layoutIfNeeded()
        
        tableHeightObserver = tableView.observe(\.cachedContentHeight) { [weak self] _, _ in
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
        let tableNeedsUpdate = headerViewNeedsStrongUpdate || footerViewNeedsStrongUpdate || tableView.superview == nil
        
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
        if tableView.superview == nil {
            tableView.frame = .init(
                origin: .init(x: 0, y: headerView?.frame.maxY ?? 0),
                size: .init(width: frame.width, height: frame.height - (headerView?.frame.height ?? 0) - (footerView?.frame.height ?? 0))
            )
            
            addSubview(tableView)
        }
        
        if tableNeedsUpdate {
            tableView.eraseConstraints()
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: headerView?.bottomAnchor ?? topAnchor),
                tableView.leadingAnchor.constraint(equalTo: tableView.superview!.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: tableView.superview!.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: footerView?.topAnchor ?? bottomAnchor),
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
