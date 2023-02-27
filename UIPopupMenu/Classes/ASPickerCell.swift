//
//  ASPickerCell.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 21.02.2023.
//

import Foundation
import UIKit

//cell
//offset from left = 32
//offset from right = 16
//top-botttom 12

//separator
//height 8, gray color

//Header
//left - 32
//top-bottom 12
//right 16

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
            
            label.translatesAutoresizingMaskIntoConstraints = false
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
            
            image.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(image)
            setNeedsUpdateConstraints()
            return image
        }
    }
    
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
            //textContainer.trailingAnchor.constraint(equalTo: textContainer.owningView!.trailingAnchor, constant: -16).priority(900)
        ])
        
        let trailing = textContainer.trailingAnchor.constraint(equalTo: textContainer.owningView!.trailingAnchor, constant: -16)
        trailing.priority = UILayoutPriority(900)
        trailing.isActive = true
        
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
}
