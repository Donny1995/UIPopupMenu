//
//  ASSectionHeaderView.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 21.02.2023.
//

import Foundation
import UIKit

class ASSectionSeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalToConstant: 8).isActive = true
        backgroundColor = UIColor.black.withAlphaComponent(0.08)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ASSectionTitleView: UIView {
    
    let titleLabel = UILabel()
    let bottomSeparatorView = UIView()
    // UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect.init(style: .systemMaterialLight), style: .separator))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSeparatorView)
        
        titleLabel.numberOfLines = 5
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor.secondaryLabel
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleLabel.superview!.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: titleLabel.superview!.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: titleLabel.superview!.trailingAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            bottomSeparatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: bottomSeparatorView.superview!.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: bottomSeparatorView.superview!.trailingAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1/UIScreen.main.scale),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomSeparatorView.superview!.bottomAnchor),
        ])
        
        bottomSeparatorView.backgroundColor = UIColor.separator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ASSectionHeaderView: UIView {
    
    let topSeparatorView = ASSectionSeparatorView()
    let titleView = ASSectionTitleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparatorView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleView)
        
        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: topSeparatorView.superview!.topAnchor),
            topSeparatorView.leadingAnchor.constraint(equalTo: topSeparatorView.superview!.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: topSeparatorView.superview!.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            titleView.leadingAnchor.constraint(equalTo: titleView.superview!.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: titleView.superview!.trailingAnchor),
            titleView.bottomAnchor.constraint(equalTo: titleView.superview!.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
