//
//  ASTableTrackingController.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 20.02.2023.
//

import Foundation
import UIKit
/*
open class ASTableTrackingController: UIViewController {
    
    public let tableView = AutoHeightTableView()
    public func updatePreferredContentSize() {
        let newSize = CGSize(
            width: UIScreen.main.bounds.width * 0.6,
            height: max(40, self.tableView.cachedContentHeight + (headerView?.frame.height ?? 0) + (footerView?.frame.height ?? 0))
        )
        
        if lastRequestedPreferredContentSize != newSize {
            lastRequestedPreferredContentSize = newSize
            preferredContentSize = newSize
        }
    }
    
    var tableHeightObserver: NSKeyValueObservation?
    var lastRequestedPreferredContentSize: CGSize?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.isScrollDisabledWhenHeightIsSufficient = true
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        //view.setNeedsUpdateConstraints()
        //view.updateConstraintsIfNeeded()
        
        tableView.reloadData()
        view.layoutIfNeeded()
        
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
            view.setNeedsUpdateConstraints()
            if let newHeader = headerView {
                newHeader.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(newHeader)
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
            view.setNeedsUpdateConstraints()
            if let newFooter = footerView {
                newFooter.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(newFooter)
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    open override func updateViewConstraints() {
        
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
            view.addSubview(tableView)
        }
        
        if tableNeedsUpdate {
            tableView.eraseConstraints()
            if let header = headerView {
                tableView.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
            } else {
                tableView.topAnchor.constraint(equalTo: tableView.superview!.topAnchor).isActive = true
            }
            
            tableView.leadingAnchor.constraint(equalTo: tableView.superview!.leadingAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: tableView.superview!.trailingAnchor).isActive = true
            
            if let footer = footerView {
                tableView.bottomAnchor.constraint(equalTo: footer.topAnchor).isActive = true
            } else {
                tableView.bottomAnchor.constraint(equalTo: tableView.superview!.bottomAnchor).isActive = true
            }
        }
        
        //footer
        if footerViewNeedsStrongUpdate {
            footerViewNeedsStrongUpdate = false
            
            if let footerView {
                footerView.eraseConstraints()
                NSLayoutConstraint.activate([
                    footerView.leadingAnchor.constraint(equalTo: footerView.superview!.leadingAnchor),
                    footerView.trailingAnchor.constraint(equalTo: footerView.superview!.trailingAnchor),
                    footerView.bottomAnchor.constraint(equalTo: footerView.superview!.bottomAnchor),
                ])
            }
        }
        
        super.updateViewConstraints()
    }
}
*/
