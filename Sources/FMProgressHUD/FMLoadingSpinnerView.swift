//
//  FMLoadingSpinnerView.swift
//  fmHUDApp
//
//  Created by Matchima Ditthawibun on 10/5/21.
//

#if !os(macOS)
import UIKit
#endif

class FMLoadingSpinnerView: UIView {
    
    
    // MARK: Config Vars
    
    var radius: CGFloat = 18 {
        didSet {
            indefiniteAnimatedLayer.removeFromSuperlayer()
            if superview != nil {
                layoutAnimatedLayer()
            }
            indefiniteAnimatedLayer.path = smoothedPath.cgPath
            indefiniteAnimatedLayer.frame = CGRect(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
            invalidateIntrinsicContentSize()
        }
    }
    var strokeColor: UIColor = .black {
        didSet {
            indefiniteAnimatedLayer.strokeColor = strokeColor.cgColor
        }
    }
    var strokeThickness: CGFloat = 2.0 {
        didSet {
            indefiniteAnimatedLayer.lineWidth = strokeThickness
            indefiniteAnimatedLayer.frame = CGRect(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: Computed Vars
    
    private var arcCenter: CGPoint {
        CGPoint(x: radius + strokeThickness / 2 + 5, y: radius + strokeThickness / 2 + 5)
    }
    
    private var smoothedPath: UIBezierPath {
        UIBezierPath(arcCenter: arcCenter,
                                        radius: radius,
                                        startAngle: -CGFloat.pi * 3 / 2,
                                        endAngle: CGFloat.pi / 2 + CGFloat.pi * 5,
                                        clockwise: true)
    }
    
    lazy var indefiniteAnimatedLayer: CAShapeLayer = {
        let indefiniteAnimatedLayer = CAShapeLayer()
        indefiniteAnimatedLayer.contentsScale = UIScreen.main.scale
        indefiniteAnimatedLayer.frame = CGRect(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
        indefiniteAnimatedLayer.fillColor = UIColor.clear.cgColor
        indefiniteAnimatedLayer.strokeColor = strokeColor.cgColor
        indefiniteAnimatedLayer.lineWidth = CGFloat(strokeThickness)
        indefiniteAnimatedLayer.lineCap = .round
        indefiniteAnimatedLayer.lineJoin = .bevel
        indefiniteAnimatedLayer.path = smoothedPath.cgPath
        
        let maskLayer = CALayer()
        maskLayer.contents = UIImage(named: "angle-mask", in: Bundle.module, with: nil)?.cgImage
        maskLayer.frame = indefiniteAnimatedLayer.bounds
        indefiniteAnimatedLayer.mask = maskLayer
        
        let animationDuration: TimeInterval = 1
        let linearCurve = CAMediaTimingFunction(name: .linear)
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Float.pi * 2
        animation.duration = animationDuration
        animation.timingFunction = linearCurve
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.infinity
        animation.fillMode = .forwards
        animation.autoreverses = false
        indefiniteAnimatedLayer.mask?.add(animation, forKey: "rotate")
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = Float.infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = linearCurve
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0.015
        strokeStartAnimation.toValue = 0.515
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.485
        strokeEndAnimation.toValue = 0.985
        
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        indefiniteAnimatedLayer.add(animationGroup, forKey: "progress")
        
        return indefiniteAnimatedLayer
    }()
    
    // MARK: Instance Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let length = (radius + strokeThickness + 5) * 2
        return CGSize(width: length, height: length)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAnimatedLayer()
    }
    
    private func layoutAnimatedLayer() {
        if indefiniteAnimatedLayer.superlayer == nil {
            layer.addSublayer(indefiniteAnimatedLayer)
        }
        
        let widthDiff = bounds.width - indefiniteAnimatedLayer.bounds.width
        let heightDiff = bounds.height - indefiniteAnimatedLayer.bounds.height
        let xPos = bounds.width - indefiniteAnimatedLayer.bounds.width / 2 - widthDiff / 2
        let yPos = bounds.height - indefiniteAnimatedLayer.bounds.height / 2 - heightDiff / 2
        indefiniteAnimatedLayer.position = CGPoint(x: xPos, y: yPos)
    }
    
}
