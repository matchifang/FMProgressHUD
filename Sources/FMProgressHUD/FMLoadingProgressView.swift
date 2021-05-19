//
//  FMLoadingProgressView.swift
//  fmHUDApp
//
//  Created by Matchima Ditthawibun on 9/5/21.
//

#if !os(macOS)
import UIKit
#endif

class FMLoadingProgressView: UIView {
    
    // MARK: Config Vars
    
    var radius: CGFloat = 18 {
        didSet {
            ringAnimatedLayer.path = smoothedPath.cgPath
            ringAnimatedLayer.frame = CGRect(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
            invalidateIntrinsicContentSize()
        }
    }
    
    var strokeEnd: CGFloat = 1.0 {
        didSet {
            ringAnimatedLayer.strokeEnd = strokeEnd
        }
    }
    
    var strokeColor: UIColor = .black {
        didSet {
            ringAnimatedLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    var strokeThickness: CGFloat = 2.0 {
        didSet {
            ringAnimatedLayer.lineWidth = strokeThickness
            ringAnimatedLayer.path = smoothedPath.cgPath
            ringAnimatedLayer.frame = CGRect(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
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
                     startAngle: -CGFloat.pi/2,
                     endAngle: CGFloat.pi + CGFloat.pi/2,
                     clockwise: true)
    }
    
    // MARK: Lazy Vars
    
    private lazy var ringAnimatedLayer: CAShapeLayer = {
        let ringAnimatedLayer = CAShapeLayer()
        ringAnimatedLayer.contentsScale = UIScreen.main.scale
        ringAnimatedLayer.frame = CGRect(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
        ringAnimatedLayer.fillColor = UIColor.clear.cgColor
        ringAnimatedLayer.strokeColor = strokeColor.cgColor
        ringAnimatedLayer.lineWidth = strokeThickness
        ringAnimatedLayer.lineCap = .round
        ringAnimatedLayer.lineJoin = .bevel
        ringAnimatedLayer.path = smoothedPath.cgPath
        
        return ringAnimatedLayer
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
        layer.addSublayer(ringAnimatedLayer)
        ringAnimatedLayer.frame = bounds
    }
}
