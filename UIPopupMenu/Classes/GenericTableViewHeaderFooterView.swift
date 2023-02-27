//
//  BaseTableViewHeaderHeaderFooterView.swift
//  BaseUIElements
//
//  Created by Alexander on 05.08.2018.
//  Copyright © 2018 Alexander Sivash. All rights reserved.
//

import Foundation
import UIKit

class GenericTableViewHeaderFooterView<ContainedType: UIView> : UITableViewHeaderFooterView {
    
    //MARK: - ❐ Variables
    
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard contentInset != oldValue else { return }
            topConstraint?.constant = contentInset.top
            leftConstraint?.constant = contentInset.left
            rightConstraint?.constant = -contentInset.right
            bottomConstraint?.constant = -contentInset.bottom
            setNeedsLayout()
        }
    }
    
    @ConstraintEnabling var topConstraint: NSLayoutConstraint?
    @ConstraintEnabling var leftConstraint: NSLayoutConstraint?
    @ConstraintEnabling var rightConstraint: NSLayoutConstraint?
    @ConstraintEnabling var bottomConstraint: NSLayoutConstraint?
    
    lazy var mViewContent: ContainedType = { [unowned self] in
        let view = ContainedType.init(frame: contentView.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        topConstraint = view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentInset.top)
        leftConstraint = view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentInset.left)
        
        rightConstraint = view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentInset.right)
        rightConstraint?.priority = UILayoutPriority(999)
        
        bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentInset.bottom)
        bottomConstraint?.priority = UILayoutPriority(999)
        
        
        return view
    }()
    
    lazy var backView: UIView = { [unowned self] in
        let view = UIView()
        self.backgroundView = view
        return view
    }()

    override var backgroundColor: UIColor? {
        set { backView.backgroundColor = newValue }
        get { return backView.backgroundColor }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = nil
        //(mViewContent as? ReusableView)?.prepareForReuse()
    }
}

@propertyWrapper
struct ConstraintEnabling {
    init() {}
    private var constraint: NSLayoutConstraint?
    var wrappedValue: NSLayoutConstraint? {
        get { return constraint }
        set {
            constraint?.isActive = false
            constraint = newValue
            constraint?.isActive = true
        }
    }
}
