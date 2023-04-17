
//
//  ASPopupPresentationView.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 11.04.2023.
//

import Foundation
import UIKit

public class ASPopupPresentationView: UIView {
    
    public static let presentAnimationDuration: TimeInterval = 0.45
    
    public let contentView: UIView
    public let interactionPoint: CGPoint?
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
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    public var canOverlapSourceViewRect: Bool = true
    public var overlapSourceViewRectScaleFactor: CGFloat = 0.7
    
    public init?(contentView: UIView, originView: UIView, interactionPoint: CGPoint? = nil) {
        guard let window = originView.window else { return nil }
        
        self.contentView = contentView
        self.originView = originView
        
        if let point = interactionPoint,
           let originViewSuperView = originView.superview,
           originViewSuperView.convert(originView.frame, to: nil).contains(point)
        {
            self.interactionPoint = point
            
        } else {
            self.interactionPoint = nil
        }
        
        super.init(frame: window.bounds)
        
        if let dynamicView = contentView as? ASPopupPresentationViewContentDynamicSize {
            dynamicView.preferredContentSizeDidChange = { [weak self] newSize in
                self?.contentViewPreferredContentSizeDidChange(newSize: newSize)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if !isViewLoaded {
            viewDidLoad()
        }
    }
    
    var isViewLoaded: Bool = false
    public func viewDidLoad() {
        isViewLoaded = true
        
        backgroundColor = .clear

        containerView.layer.isDoubleSided = false
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.clear
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: blurView.superview!.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: blurView.superview!.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: blurView.superview!.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: blurView.superview!.bottomAnchor),
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: contentView.superview!.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentView.superview!.trailingAnchor).priority(800),
            contentView.topAnchor.constraint(equalTo: contentView.superview!.topAnchor),
        ])
        
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: contentView.superview!.bottomAnchor).priority(900).activate()
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 64
        
        positionContentViewIfNeeded(params: nil)
        //view.updateConstraintsIfNeeded()
        layoutIfNeeded()
        updateShadowParams()
    }
    
    var contentViewSizeChangedDuringLock: Bool = false
    var contentViewSizeUpdateLocked: Bool = false {
        didSet {
            guard contentViewSizeUpdateLocked != oldValue, contentViewSizeUpdateLocked == false else { return }
            if contentViewSizeChangedDuringLock {
                contentViewSizeChangedDuringLock = false
                contentViewPreferredContentSizeDidChange(newSize: .zero)
            }
        }
    }
    
    var cachedSizeOfContentView: CGSize?
    var contentViewPreferredContentSizeUpdateToken: TimeInterval = .nan
    func contentViewPreferredContentSizeDidChange(newSize: CGSize) {
        
        guard !(contentViewSizeUpdateLocked && isBeingPresented && isBeingDismissed) else {
            contentViewSizeChangedDuringLock = true
            return
        }
        
        guard let newParams = calculateContainerViewFrame(), cachedSizeOfContentView != newParams.rect.size else { return }
        cachedSizeOfContentView = newParams.rect.size
        contentViewSizeUpdateLocked = true
        
        func performAnimationActions() {
            positionContentViewIfNeeded(params: newParams)
            
            layoutIfNeeded()
            contentView.fadeTransitionAnimation(duration: 1/3)
            updateShadowParams()
        }
        
        if isBeingPresented || isBeingDismissed {
            performAnimationActions()
            
        } else {
            let newToken = Date().timeIntervalSince1970
            contentViewPreferredContentSizeUpdateToken = newToken
            UIView.animate(withDuration: 1/3, delay: 0.0, options: [.beginFromCurrentState, .layoutSubviews, .allowAnimatedContent], animations: performAnimationActions) { [weak self] _ in
                guard let self, self.contentViewPreferredContentSizeUpdateToken == newToken else {
                    return
                }
                
                self.contentViewSizeUpdateLocked = false
            }
        }
    }
    
    func updateShadowParams() {
        let criteria = min(85, min(containerView.bounds.height, containerView.bounds.width))
        layer.shadowOpacity = 1.0 - Float(criteria * (1 - 0.22) / 85)
    }
    
    ///Return true, if content view is oriented from to to bottom
    @discardableResult
    func positionContentViewIfNeeded(params: (rect: CGRect, goesDown: Bool)? = nil) -> Bool? {
        guard let params = params ?? calculateContainerViewFrame() else { return nil }
        guard containerView.frame != params.rect else {
            return params.goesDown
        }
        
        let newFrame = params.rect
        
        if let containerViewXOffsetConstraint {
            if containerViewXOffsetConstraint.constant != newFrame.minX {
                containerViewXOffsetConstraint.constant = newFrame.minX
            }
            
        } else {
            containerViewXOffsetConstraint = containerView.leftAnchor.constraint(equalTo: containerView.superview!.leftAnchor, constant: newFrame.minX).activate()
        }
        
        if let containerViewYOffsetConstraint {
            if containerViewYOffsetConstraint.constant != newFrame.minY {
                containerViewYOffsetConstraint.constant = newFrame.minY
            }
            
        } else {
            containerViewYOffsetConstraint = containerView.topAnchor.constraint(equalTo: containerView.superview!.topAnchor, constant: newFrame.minY).activate()
        }
        
        if let containerViewHeightConstraint {
            if containerViewHeightConstraint.constant != newFrame.height {
                containerViewHeightConstraint.constant = newFrame.height
            }
            
        } else {
            containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: newFrame.height).activate()
        }
        
        if let containerViewWidthConstraint {
            if containerViewWidthConstraint.constant != newFrame.width {
                containerViewWidthConstraint.constant = newFrame.width
            }
            
        } else {
            containerViewWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: newFrame.width).activate()
        }
        
        return params.goesDown
    }
    
    var cachedOriginViewRect: CGRect = .zero
    var cachedAvailableArea: CGRect = .zero
    var cachedSafeInsets: UIEdgeInsets = .zero
    
    func calculateContainerViewFrame() -> (rect: CGRect, goesDown: Bool)? {
        if let originView {
            cachedOriginViewRect = originView.superview!.convert(originView.frame, to: nil).insetBy(dx: 0, dy: -8)
            
        } else {
            print("well, some weird shit happend")
        }
        
        if let window = originView?.window {
            cachedSafeInsets = window.safeAreaInsets
            
            cachedAvailableArea = window.bounds.inset(by: UIEdgeInsets(
                top: max(cachedSafeInsets.top, 16),
                left: max(cachedSafeInsets.left, 16),
                bottom: max(cachedSafeInsets.bottom, 16),
                right: max(cachedSafeInsets.right, 16)
            ))
            
            
            
            let keyboardFrame = KeyboardListener.keyboardRect
            if keyboardFrame != CGRect.null {
                cachedSafeInsets.bottom += keyboardFrame.height
            }
        }
        
        let originViewFrame = cachedOriginViewRect
        let availableArea = cachedAvailableArea
        let originViewSafeInsets = cachedSafeInsets
        
        let preferredSize: CGSize = {
            if let size = (contentView as? ASPopupPresentationViewContentDynamicSize)?.preferredContentSize {
                return size
                
            } else {
                var candidate = self.contentView.intrinsicContentSize
                lazy var systemLayoutSize = self.contentView.systemLayoutSizeFitting(availableArea.size)
                if candidate.width == UIView.noIntrinsicMetric {
                    candidate.width = systemLayoutSize.width
                }
                
                if candidate.height == UIView.noIntrinsicMetric {
                    candidate.height = systemLayoutSize.height
                }
                
                return candidate
            }
        }()
        
        let clampedWidth = min(availableArea.width, max(60, preferredSize.width))
        
        let xOrigin = (interactionPoint?.x ?? originViewFrame.midX).clamped(
            min: availableArea.minX + clampedWidth/2,
            max: availableArea.maxX - clampedWidth/2
        ) - clampedWidth/2
        
        let spaceBelow = UIScreen.main.bounds.height - originViewFrame.maxY - originViewSafeInsets.bottom
        let spaceAbove = originViewFrame.minY - originViewSafeInsets.top
        var clampedHeight = min(max(spaceBelow, spaceAbove), max(40, preferredSize.height))
        
        var goesBelow = originViewFrame.midY <= UIScreen.main.bounds.height / 2
        let bottomSpaceIsMoreThanEnough = spaceBelow >= preferredSize.height
        let upperSpaceIsMoreThanEnough = spaceAbove >= preferredSize.height
        
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
            let clampedScaleFactor = overlapSourceViewRectScaleFactor.clamped(min: 0.0, max: 1.0)
            let overlapScaledHeight = min(availableArea.height, preferredSize.height) * clampedScaleFactor
            if clampedHeight < overlapScaledHeight {
                let difference = overlapScaledHeight - clampedHeight
                if goesBelow {
                    yOrigin -= difference
                    clampedHeight += difference
                    
                } else {
                    clampedHeight += difference
                }
            }
        }
        
        let finalFrame = CGRect(
            origin: .init(x: xOrigin, y: yOrigin),
            size: CGSize(width: clampedWidth, height: clampedHeight)
        )
        
        return (finalFrame, goesBelow)
    }
    
    //MARK: - 📦 Transitions
    
    public private (set) var isBeingPresented: Bool = false
    public func present(animated: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        guard
            let transitionContainerView = originView?.viewController?.rootController.view,
            !isBeingPresented
        else {
            completion?(false)
            return
        }
        
        isBeingPresented = true
        contentViewSizeUpdateLocked = true
        
        if animated {
            
            let wasAutoresizing = autoresizesSubviews
            containerView.alpha = 0.0
            
            transitionContainerView.addSubview(self)
            
            let params = calculateContainerViewFrame()
            let goesBelow = positionContentViewIfNeeded(params: params) ?? true
            layoutIfNeeded()
            containerView.layoutSubviews()
            autoresizesSubviews = false
            
            let yOriginShift: CGFloat = goesBelow ? 0.0 : 1.0
            var xOriginShift: CGFloat = 0.5
            var yOriginShiftOffset: CGFloat = 0.0
            
            if let originView,
               let containerFrameInWindowCoords = containerView.globalFrame,
               let originViewFrameInWindowCoords = originView.globalFrame
            {
                let containerCenterInWindowCoords = containerFrameInWindowCoords.center.x
                let intracationCenterInWindowCoords = interactionPoint?.x ?? originViewFrameInWindowCoords.center.x
                let criteria = (containerCenterInWindowCoords - intracationCenterInWindowCoords)/containerView.bounds.width
                xOriginShift -= max(-0.5, min(0.5, criteria))
                
                if originViewFrameInWindowCoords.intersects(containerFrameInWindowCoords) {
                    if goesBelow {
                        yOriginShiftOffset = (originViewFrameInWindowCoords.center.y - containerFrameInWindowCoords.origin.y) / containerFrameInWindowCoords.size.height
                        
                    } else {
                        yOriginShiftOffset = -(containerFrameInWindowCoords.maxY - originViewFrameInWindowCoords.center.y) / containerFrameInWindowCoords.size.height
                    }
                }
            } else {
                print("transition lagged")
            }
            
            let originalHeight = containerView.bounds.size.height
            
            containerView.shiftAnchorPoint(to: .init(x: xOriginShift, y: yOriginShift + yOriginShiftOffset))
            containerView.transform = .init(scaleX: 0.1, y: 0.1)
            containerView.bounds.size.height *= 0.2
            autoresizesSubviews = false
            
            UIView.animate(withDuration: ASPopupPresentationView.presentAnimationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.allowAnimatedContent]) { [self] in
                containerView.alpha = 1.0
                containerView.transform = .identity
                containerView.bounds.size.height = originalHeight
                
            } completion: { [weak self] _ in
                guard let self else { return }
                self.containerView.shiftAnchorPoint(to: .init(x: 0.5, y: 0.5))
                self.autoresizesSubviews = wasAutoresizing
                self.isBeingPresented = false
                self.contentViewSizeUpdateLocked = false
                self.subscribeForKeyboardNotifications()
                completion?(true)
            }
            
        } else {
            removeFromSuperview()
            originView!.addSubview(self)
            isBeingPresented = false
            contentViewSizeUpdateLocked = false
            completion?(true)
        }
    }
    
    public private (set) var isBeingDismissed: Bool = false
    public func dismiss(animated: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        guard !isBeingDismissed, superview != nil else {
            completion?(false)
            return
        }
        
        isBeingDismissed = true
        contentViewSizeUpdateLocked = true
        unSubscribeFromKeyboardNotifications()
        
        if animated {
            
            let wasAutoresizing = autoresizesSubviews
            let goesBelow = calculateContainerViewFrame()?.goesDown ?? true
            
            autoresizesSubviews = false
            
            let yOriginShift: CGFloat = goesBelow ? 0.0 : 1.0
            var xOriginShift: CGFloat = 0.5
            var yOriginShiftOffset: CGFloat = 0.0
            
            if let originView,
               let containerFrameInWindowCoords = containerView.globalFrame,
               let originViewFrameInWindowCoords = originView.globalFrame
            {
                let containerCenterInWindowCoords = containerFrameInWindowCoords.center.x
                let intracationCenterInWindowCoords = interactionPoint?.x ?? originViewFrameInWindowCoords.center.x
                let criteria = (containerCenterInWindowCoords - intracationCenterInWindowCoords)/containerView.bounds.width
                xOriginShift -= max(-0.5, min(0.5, criteria))
                
                if originViewFrameInWindowCoords.intersects(containerFrameInWindowCoords) {
                    if goesBelow {
                        yOriginShiftOffset = (originViewFrameInWindowCoords.center.y - containerFrameInWindowCoords.origin.y) / containerFrameInWindowCoords.size.height
                        
                    } else {
                        yOriginShiftOffset = -(containerFrameInWindowCoords.maxY - originViewFrameInWindowCoords.center.y) / containerFrameInWindowCoords.size.height
                    }
                }
            }
            
            containerView.shiftAnchorPoint(to: .init(x: xOriginShift, y: yOriginShift + yOriginShiftOffset))
            let originalHeight = containerView.bounds.size.height
            
            UIView.animate(withDuration: ASPopupPresentationView.presentAnimationDuration/1.5, delay: 0.0, options: []) { [self] in
                containerView.alpha = 0.0
                containerView.transform = .init(scaleX: 0.1, y: 0.1)
                containerView.bounds.size.height *= 0.2
                
            } completion: { [weak self] _ in
                guard let self else { return }
                self.removeFromSuperview()
                self.containerView.bounds.size.height = originalHeight
                self.containerView.transform = .identity
                self.containerView.shiftAnchorPoint(to: .init(x: 0.5, y: 0.5))
                self.autoresizesSubviews = wasAutoresizing
                
                self.isBeingDismissed = false
                self.contentViewSizeUpdateLocked = false
                
                completion?(true)
            }
            
        } else {
            removeFromSuperview()
            contentViewSizeUpdateLocked = false
            isBeingDismissed = false
            completion?(true)
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if containerView.frame.contains(point) {
            return super.hitTest(point, with: event)
            
        } else {
            defer {
                dismiss(animated: true)
            }
            
            if let originViewFrame = originView?.globalFrame, originViewFrame.contains(point) {
                return self
                
            } else {
                return nil
            }
        }
    }
    
    //MARK: - 📦 Keyboard
    var observations: [NSObjectProtocol] = []
    func subscribeForKeyboardNotifications() {
        observations = [
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
                self?.contentViewPreferredContentSizeDidChange(newSize: .zero)
            },
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
                self?.contentViewPreferredContentSizeDidChange(newSize: .zero)
            },
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] notification in
                self?.contentViewPreferredContentSizeDidChange(newSize: .zero)
            }
        ]
    }
    
    func unSubscribeFromKeyboardNotifications() {
        for observation in observations {
            NotificationCenter.default.removeObserver(observation)
        }
    }
}

public protocol ASPopupPresentationViewContentDynamicSize: UIView {
    var preferredContentSizeDidChange: ((_ newSize: CGSize) -> Void)? { get set }
    var preferredContentSize: CGSize { get }
}

extension ASPopupPresentationViewContentDynamicSize {
    func dismiss(animated: Bool) {
        let dismissableParent = sequence(first: self, next: \.superview)
            .first(where: { $0 is ASPopupPresentationView })
            as? ASPopupPresentationView
        
        dismissableParent?.dismiss(animated: animated)
    }
}
