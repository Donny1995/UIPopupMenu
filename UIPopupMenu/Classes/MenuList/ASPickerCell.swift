//
//  ASPickerCell.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 21.02.2023.
//

import Foundation
import UIKit

class ASPickerCell: UITableViewCell {
    
    var titleLabel = UILabel()
    let textContainer = UILayoutGuide()
    
    private var _subTitleLabel: UILabel?
    var hasSubtitleLabel: Bool { return _subTitleLabel != nil }
    var subTitleLabel: UILabel {
        get {
            let label = _subTitleLabel ?? {
                let label = UILabel()
                _subTitleLabel = label
                return label
            }()
            
            contentView.addSubview(label)
            setNeedsUpdateConstraints()
            return label
        }
    }
    
    private(set) var hasLeftImageView: Bool = false
    lazy var imageViewLeft: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        hasLeftImageView = true
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageView.superview!.leadingAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.centerYAnchor.constraint(equalTo: imageView.superview!.centerYAnchor),
        ])
        
        return imageView
    }()
    
    private var _imageViewRight: UIImageView?
    var hasRightImage: Bool { return _imageViewRight != nil }
    var imageViewRight: UIImageView {
        get {
            let image = _imageViewRight ?? {
                let imageView = UIImageView()
                _imageViewRight = imageView
                return imageView
            }()
            
            contentView.addSubview(image)
            setNeedsUpdateConstraints()
            return image
        }
    }
    
    private(set) var hasHighlightView: Bool = false
    lazy var highlightView: UIView = { [unowned self] in
        let highlightView = UIView()
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        highlightView.backgroundColor = UIColor.systemGray4
        contentView.insertSubview(highlightView, at: 0)
        hasHighlightView = true
        
        NSLayoutConstraint.activate([
            highlightView.leadingAnchor.constraint(equalTo: highlightView.superview!.leadingAnchor),
            highlightView.topAnchor.constraint(equalTo: highlightView.superview!.topAnchor),
            highlightView.bottomAnchor.constraint(equalTo: highlightView.superview!.bottomAnchor),
            highlightView.trailingAnchor.constraint(equalTo: highlightView.superview!.trailingAnchor),
        ])
        
        return highlightView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addLayoutGuide(textContainer)
        contentView.addSubview(titleLabel)
        setNeedsUpdateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(constraints)
        subviews.forEach { NSLayoutConstraint.deactivate($0.constraints) }
        
        NSLayoutConstraint.activate([
            textContainer.topAnchor.constraint(equalTo: textContainer.owningView!.topAnchor, constant: 12),
            textContainer.leadingAnchor.constraint(equalTo: textContainer.owningView!.leadingAnchor, constant: 32),
            textContainer.bottomAnchor.constraint(equalTo: textContainer.owningView!.bottomAnchor, constant: -12),
            textContainer.trailingAnchor.constraint(equalTo: textContainer.owningView!.trailingAnchor, constant: -16).priority(900)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: textContainer.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: textContainer.bottomAnchor),
        ])
        
        if _imageViewRight?.image == nil {
            _imageViewRight?.removeFromSuperview()
        }
        
        if _subTitleLabel?.text?.isEmpty ?? true {
            _subTitleLabel?.removeFromSuperview()
        }
        
        if let _subTitleLabel, _subTitleLabel.superview == contentView {
            _subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                _subTitleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
                _subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: textContainer.trailingAnchor),
                _subTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: textContainer.bottomAnchor)
            ])
        }
        
        if let _imageViewRight, _imageViewRight.superview == contentView {
            _imageViewRight.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _imageViewRight.centerYAnchor.constraint(equalTo: _imageViewRight.superview!.centerYAnchor),
                _imageViewRight.trailingAnchor.constraint(equalTo: _imageViewRight.superview!.trailingAnchor, constant: -16),
                _imageViewRight.widthAnchor.constraint(equalToConstant: 20),
                _imageViewRight.heightAnchor.constraint(equalToConstant: 20),
                textContainer.trailingAnchor.constraint(equalTo: _imageViewRight.leadingAnchor, constant: -16)
            ])
        }
        
        if hasLeftImageView {
            NSLayoutConstraint.activate([
                imageViewLeft.leadingAnchor.constraint(equalTo: imageViewLeft.superview!.leadingAnchor, constant: 8),
                imageViewLeft.widthAnchor.constraint(equalToConstant: 20),
                imageViewLeft.heightAnchor.constraint(equalToConstant: 20),
                imageViewLeft.centerYAnchor.constraint(equalTo: imageViewLeft.superview!.centerYAnchor),
            ])
        }
        
        super.updateConstraints()
    }
    
    var showsLeftImageOnSelect: Bool = true
    var menuSelectionStyle: ASPickableListView.CellItem.SelectionType? {
        didSet {
            guard menuSelectionStyle != oldValue, let menuSelectionStyle else { return }
            switch menuSelectionStyle {
            case .gray:
                selectionStyle = .gray
                showsLeftImageOnSelect = false
                
            case .tick:
                selectionStyle = .none
                showsLeftImageOnSelect = true
            }
            
            setSelected(isSelected, animated: false)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let wasSelected = isSelected
        
        super.setSelected(selected, animated: animated)
        guard wasSelected != selected && showsLeftImageOnSelect else { return }
        
        func commit() {
            if selected {
                imageViewLeft.image = UIImage(systemName: "checkmark")
                imageViewLeft.alpha = 1.0
                
            } else if hasLeftImageView {
                imageViewLeft.alpha = 0.0
            }
            
        }
        
        imageViewLeft.layoutIfNeeded()
        
        if animated {
            UIView.animate(withDuration: 1/3, animations: commit)
            
        } else {
            commit()
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if selectionStyle == .none {
            
            if highlighted {
                highlightView.alpha = 1.0
                
            } else if hasHighlightView {
                highlightView.alpha = 0.0
            }
            
        } else {
            super.setHighlighted(highlighted, animated: animated)
        }
    }
}
