//
//  ASCutoutShadowView.swift
//  UIComponents
//
//  Created by Alexandr Sivash on 18.02.2023.
//

import UIKit
import CoreGraphics
/*
class ASCutoutShadowView: UIView {
    
    struct ShadowDescriptor {
        let color: UIColor
        let offset: CGSize
        let blurRadius: CGFloat
        let alpha: CGFloat
    }
    
    weak var patient: UIView?
    let shadowParams: ShadowDescriptor
    let constant: CGFloat = 128
    
    init(forView: UIView, shadowParams: ShadowDescriptor) {
        self.patient = forView
        self.shadowParams = shadowParams
        super.init(frame: forView.frame.insetBy(dx: -constant*2, dy: -constant*2))
        isOpaque = false
        layer.isDoubleSided = false
        isUserInteractionEnabled = false
    }
    
    var cachedSize: CGSize?
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if cachedSize != bounds.size {
            cachedSize = bounds.size
            
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let patient, let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setShadow(
            offset: shadowParams.offset,
            blur: shadowParams.blurRadius,
            color: shadowParams.color.withAlphaComponent(shadowParams.alpha).cgColor
        )
        
        //2 draw rect
        let path = UIBezierPath(
            roundedRect: CGRect(origin: .init(x: constant, y: constant), size: patient.bounds.size),
            cornerRadius: patient.layer.cornerRadius
        )

        context.beginPath()
        context.addPath(path.cgPath)
        context.closePath()
        context.setFillColor(UIColor.red.cgColor)
        context.fillPath()
        
        context.setShadow(offset: .zero, blur: 0, color: nil)
        
        context.beginPath()
        context.addPath(path.cgPath)
        context.closePath()
        context.setFillColor(UIColor.white.cgColor)
        context.clip(using: .evenOdd)
        context.clear(CGRect(origin: .init(x: constant, y: constant), size: patient.bounds.size))
        
        cachedSize = bounds.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
*/
