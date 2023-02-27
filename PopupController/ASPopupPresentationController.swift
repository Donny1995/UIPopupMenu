//
//  PopupPresentationController.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 17.02.2023.
//

import Foundation
import UIKit

public class ASPopupPresentationController: UIViewController {
    
    public let contentViewController: UIViewController
    public internal(set) weak var originView: UIView? {
        didSet {
            guard isViewLoaded else { return }
            positionContentViewIfNeeded()
        }
    }
    
    var containerViewXOffsetConstraint: NSLayoutConstraint?
    var containerViewYOffsetConstraint: NSLayoutConstraint?
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewWidthConstraint: NSLayoutConstraint?
    
    var contentViewBottomConstraint: NSLayoutConstraint?
    
    let containerView: UIView = UIView(frame: CGRect(origin: .zero, size: CGSize(
        width: UIScreen.main.bounds.width/2,
        height: UIScreen.main.bounds.height/2
    )))
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
    var preferredContentSizeObservation: NSKeyValueObservation?
    
    var canOverlapSourceViewRect: Bool = true
    
    ///Still, greater than 50 and less than available screen space
    var maxHeight: CGFloat?
    
    public init(contentViewController: UIViewController, originView: UIView) {
        self.contentViewController = contentViewController
        self.originView = originView
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOuterArea(sender:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        containerView.layer.isDoubleSided = false
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: blurView.superview!.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: blurView.superview!.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: blurView.superview!.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: blurView.superview!.bottomAnchor),
        ])
        
        let contentView: UIView! = contentViewController.view
        addChild(contentViewController)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(contentViewController.view)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: contentView.superview!.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentView.superview!.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: contentView.superview!.topAnchor),
        ])
        
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: contentView.superview!.bottomAnchor)
        contentViewBottomConstraint?.isActive = true
        
        contentViewController.didMove(toParent: self)
        //containerView.layoutIfNeeded()
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 64
        
        var unlocked: Bool = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            unlocked = true //Temporary measure to cut out all layout passes
        }
        
        var cachedSizeOfChildController: CGSize?
        preferredContentSizeObservation = contentViewController.observe(\.preferredContentSize, changeHandler: { [weak self] _, _ in
            guard let self, let newParams = self.calculateContainerViewFrame(), cachedSizeOfChildController != newParams.rect.size else { return }
            cachedSizeOfChildController = newParams.rect.size
            
            if unlocked && !self.isBeingPresented {
                UIView.animate(withDuration: 1/3, delay: 0.0, options: [.beginFromCurrentState, .layoutSubviews, .allowAnimatedContent]) {
                    self.positionContentViewIfNeeded(params: newParams)
                    self.view.layoutIfNeeded()
                    self.containerView.layoutIfNeeded()
                    
                    let a = CATransition()
                    a.type = .fade
                    a.fillMode = .forwards
                    a.duration = 1/3
                    self.contentViewController.view.layer.add(a, forKey: "fadeTransitionAnimation")
                    
                    self.updateShadowParams()
                }
                
            } else {
                
                self.positionContentViewIfNeeded(params: newParams)
                self.view.layoutIfNeeded()
                self.updateShadowParams()
            }
        })
        
        positionContentViewIfNeeded(params: nil)
        //view.updateConstraintsIfNeeded()
        view.layoutIfNeeded()
        updateShadowParams()
    }
    
    func updateShadowParams() {
        let criteria = min(64, min(containerView.bounds.height, containerView.bounds.width))
        view.layer.shadowOpacity = 1.0 - Float(criteria * (1 - 0.20) / 64.0) //По приближении
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    ///Return true, if content view is oriented from to to bottom
    @discardableResult
    func positionContentViewIfNeeded(params: (rect: CGRect, goesDown: Bool)? = nil) -> Bool? {
        guard let params = params ?? calculateContainerViewFrame() else { return nil }
        guard containerView.frame != params.rect else { return params.goesDown }
        
        let newFrame = params.rect
        
        if let containerViewXOffsetConstraint, containerViewXOffsetConstraint.constant != newFrame.minX {
            containerViewXOffsetConstraint.constant = newFrame.minX
        } else {
            containerViewXOffsetConstraint = containerView.leftAnchor.constraint(equalTo: containerView.superview!.leftAnchor, constant: newFrame.minX)
            containerViewXOffsetConstraint?.isActive = true
        }
        
        if let containerViewYOffsetConstraint, containerViewYOffsetConstraint.constant != newFrame.minY {
            containerViewYOffsetConstraint.constant = newFrame.minY
        } else {
            containerViewYOffsetConstraint = containerView.topAnchor.constraint(equalTo: containerView.superview!.topAnchor, constant: newFrame.minY)
            containerViewYOffsetConstraint?.isActive = true
        }
        
        if let containerViewHeightConstraint, containerViewHeightConstraint.constant != newFrame.height {
            containerViewHeightConstraint.constant = newFrame.height
            
        } else {
            containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: newFrame.height)
            containerViewHeightConstraint?.isActive = true
        }
        
        if let containerViewWidthConstraint, containerViewWidthConstraint.constant != newFrame.width {
            containerViewWidthConstraint.constant = newFrame.width
            
        } else {
            containerViewWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: newFrame.width)
            containerViewWidthConstraint?.isActive = true
        }
        
        return params.goesDown
    }
    
    func calculateContainerViewFrame() -> (rect: CGRect, goesDown: Bool)? {
        guard let originView, let window = originView.window else { return nil }
        let originViewFrame = originView.convert(originView.bounds, to: nil)
        let originViewSafeInsets = originView.viewController?.view.safeAreaInsets ?? view.safeAreaInsets
        
        let insets = UIEdgeInsets(
            top: max(originViewSafeInsets.top, 16),
            left: max(originViewSafeInsets.left, 16),
            bottom: max(originViewSafeInsets.bottom, 16),
            right: max(originViewSafeInsets.right, 16)
        )
        
        let availableArea = window.bounds.inset(by: insets)
        let clampedWidth = min(availableArea.width, max(60, contentViewController.preferredContentSize.width))
        
        let xOrigin = originViewFrame.midX.clamp(
            min: availableArea.minX + clampedWidth/2,
            max: availableArea.maxX - clampedWidth/2
        ) - clampedWidth/2
        
        let spaceBelow = UIScreen.main.bounds.height - originViewFrame.maxY - originViewSafeInsets.bottom
        let spaceAbove = originViewFrame.minY - originViewSafeInsets.top
        var clampedHeight = min(max(spaceBelow, spaceAbove), max(50, contentViewController.preferredContentSize.height))
        
        var goesBelow = originViewFrame.midY <= UIScreen.main.bounds.height / 2
        let bottomSpaceIsMoreThanEnough = spaceBelow >= contentViewController.preferredContentSize.height
        let upperSpaceIsMoreThanEnough = spaceAbove >= contentViewController.preferredContentSize.height
        
        if !bottomSpaceIsMoreThanEnough && !upperSpaceIsMoreThanEnough {
            goesBelow = spaceBelow > spaceAbove
            
        } else if goesBelow && !bottomSpaceIsMoreThanEnough {
            goesBelow = spaceBelow > spaceAbove
            
        } else if !goesBelow && !upperSpaceIsMoreThanEnough {
            goesBelow = spaceAbove > spaceBelow
        }
        
        var yOrigin: CGFloat = goesBelow
            ? originViewFrame.maxY
            : originViewFrame.minY - clampedHeight
        
        if canOverlapSourceViewRect {
            if clampedHeight < contentViewController.preferredContentSize.height && contentViewController.preferredContentSize.height <= availableArea.height {
                if goesBelow {
                    yOrigin -= contentViewController.preferredContentSize.height - clampedHeight
                    clampedHeight = contentViewController.preferredContentSize.height
                    
                } else {
                    clampedHeight = contentViewController.preferredContentSize.height
                }
            }
        }
        
        let finalFrame = CGRect(
            origin: .init(x: xOrigin, y: yOrigin),
            size: CGSize(width: clampedWidth, height: clampedHeight)
        )
        
        window.convert(finalFrame, to: view)
        
        return (finalFrame, goesBelow)
    }
    
    @objc func didTapOuterArea(sender: UITapGestureRecognizer) {
        guard !isBeingDismissed else { return }
        guard !containerView.frame.contains(sender.location(in: view)) else { return }
        dismiss(animated: true)
    }
}

extension Comparable {
    fileprivate func clamp(min minimum: Self, max maximum: Self) -> Self {
        return max(min(maximum, self), minimum)
    }
}

