//
//  FMProgressHUD.swift
//  fmHUDApp
//
//  Created by Matchima Ditthawibun on 11/5/21.
//

#if !os(macOS)
import UIKit
#endif


/// mask of the background when HUD is visible
public enum FMProgressHUDMaskType {
    case clear
    case black
    case custom
}

/// Animation of the loading spinner:
/// 1. flat - animated ring spinner
/// 2. native - iOS native UIActivityIndicatorView
public enum FMProgressHUDAnimationType {
    case flat
    case native
}

/// Style of progress HUD, which determines the foreground and background colors of the HUD, label, and spinner
public enum FMProgressHUDStyle {
    case light
    case dark
    case custom
}


/**
 Singleton class for showing progress HUD
 
 HUD comprises of 2 sections: 1. image and 2. status. Image section can show image, loading spinner, or progress ring. Status section is optional and can be omitted
 
 HUD should show either one of the following combinations:
 
 1. indefinite loading spinner
 
 2. indefinite loading spinner with status
 
 3. progress loading spinner
 
 4. progress loading spinner with status
 
 5. image
 
 6. image with status
 */
public class FMProgressHUD {
    
    // MARK: Config Vars
    
    /// Fade in animation duration when a HUD is shown - default is `0.15`
    public static var fadeInAnimationDuration: TimeInterval = 0.15
    
    /// Fade out animation duration when a HUD is dismissed - default is `0.15`
    public static var fadeOutAnimationDuration: TimeInterval = 0.15
    
    /// Image size - default is `CGSize(width: 28, height: 28)`
    public static var imageSize = CGSize(width: 28, height: 28)
    
    /// Animation of the loading spinner - default is `FMProgressHUDAnimationType.flat`
    public static var animationType = FMProgressHUDAnimationType.flat
    
    /// Style that determines foregorund, background, and blur effect colors  - default is `FMProgressHUDStyle.light`
    public static var hudStyle = FMProgressHUDStyle.light {
        didSet {
            if hudStyle != .custom {
                let blurEffectStyle: UIBlurEffect.Style = hudStyle == .dark ? .dark : .light
                let blurEffect = UIBlurEffect(style: blurEffectStyle)
                FMProgressHUD.shared.hudView.effect = blurEffect
            } else {
                FMProgressHUD.shared.hudView.effect = hudViewCustomBlurEffect
            }
            let foregroundColorForStyle = FMProgressHUD.shared.foregroundColorForStyle
            FMProgressHUD.shared.hudView.backgroundColor = FMProgressHUD.shared.backgroundColorForStyle.withAlphaComponent(0.6)
            FMProgressHUD.shared.backgroundRingView.strokeColor = foregroundColorForStyle.withAlphaComponent(0.1)
            FMProgressHUD.shared.nativeSpinner.color = foregroundColorForStyle
            FMProgressHUD.shared.flatSpinner.strokeColor = foregroundColorForStyle
            FMProgressHUD.shared.statusLabel.textColor = foregroundColorForStyle
            FMProgressHUD.shared.imageView?.tintColor = foregroundColorForStyle
        }
    }
    
    /// HUD background's background color - default is `UIColor.clear`
    public static var backgroundColor = UIColor.clear {
        didSet {
            FMProgressHUD.shared.backgroundView.backgroundColor = backgroundColor
        }
    }
    
    /// HUD foregorund color  - default is `UIColor.black`
    public static var hudForegroundColor = UIColor.black {
        didSet {
            let foregroundColorForStyle = FMProgressHUD.shared.foregroundColorForStyle
            FMProgressHUD.shared.nativeSpinner.color = foregroundColorForStyle
            FMProgressHUD.shared.flatSpinner.strokeColor = foregroundColorForStyle
            FMProgressHUD.shared.backgroundRingView.strokeColor = foregroundColorForStyle.withAlphaComponent(0.1)
            FMProgressHUD.shared.nativeSpinner.color = foregroundColorForStyle
            FMProgressHUD.shared.statusLabel.textColor = foregroundColorForStyle
            FMProgressHUD.shared.imageView?.tintColor = foregroundColorForStyle
        }
    }
    
    /// HUD's background color - default is `UIColor.white`
    public static var hudBackgroundColor = UIColor.white {
        didSet {
            FMProgressHUD.shared.hudView.backgroundColor = FMProgressHUD.shared.backgroundColorForStyle
        }
    }
    
    /// HUD background's background mask type - default is `FMProgressHUDMaskType.clear`
    public static var maskType = FMProgressHUDMaskType.clear {
        didSet {
            switch maskType {
            case .black:
                FMProgressHUD.shared.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.4)
            case .custom:
                FMProgressHUD.shared.backgroundView.backgroundColor = FMProgressHUD.backgroundColor
            default:
                FMProgressHUD.shared.backgroundView.backgroundColor = .clear
            }
        }
    }
    
    /// Custom blur effect on the HUD when style is `FMProgressHUDAnimationType.custom` - default is `nil`
    public static var hudViewCustomBlurEffect: UIBlurEffect? {
        didSet {
            if hudStyle == .custom {
                FMProgressHUD.shared.hudView.effect = hudViewCustomBlurEffect
            }
        }
    }
    
    /// Whether or not user interactions are allowed while the HUD is shown - default is `false`
    public static var allowUserInteraction = true {
        didSet {
            FMProgressHUD.shared.backgroundView.disableTouch = !allowUserInteraction
        }
    }
    
    /// Corner radius of the HUD - default is `14`
    public static var cornerRadius: CGFloat = 14 {
        didSet {
            FMProgressHUD.shared.hudView.layer.cornerRadius = cornerRadius
        }
    }
    
    /// Ring thickness of the ring spinner - default is `2`
    public static var ringThickness: CGFloat = 2 {
        didSet {
            FMProgressHUD.shared.flatSpinner.strokeThickness = ringThickness
            FMProgressHUD.shared.ringView.strokeThickness = ringThickness
            FMProgressHUD.shared.backgroundRingView.strokeThickness = ringThickness
        }
    }
    
    // TODO: allow user to set ring radius
    /// Ring radius of the ring spinner - default is `18`
    private static var ringRadius: CGFloat = 18 {
        didSet {
            FMProgressHUD.shared.flatSpinner.radius = ringRadius
            FMProgressHUD.shared.ringView.radius = ringRadius
            FMProgressHUD.shared.backgroundRingView.radius = ringRadius
        }
    }
    
    /// Status label font size - default is `15`
    public static var labelFontSize: CGFloat = 15 {
        didSet {
            FMProgressHUD.shared.statusLabel.font = UIFont.systemFont(ofSize: labelFontSize)
        }
    }
    
    // MARK: Static constants
    
    private static let shared = FMProgressHUD()
    private static let VERTICAL_SPACING: CGFloat = 12
    private static let HORIZONTAL_SPACING: CGFloat = 12
    
    // MARK: Lazy Vars
    
    private lazy var nativeSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.accessibilityIdentifier = "FMProgressHUD_nativeSpinner"
        indicator.startAnimating()
        indicator.color = FMProgressHUD.hudForegroundColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private lazy var flatSpinner: FMLoadingSpinnerView = {
        let flatSpinner = FMLoadingSpinnerView()
        flatSpinner.accessibilityIdentifier = "FMProgressHUD_flatSpinner"
        flatSpinner.strokeColor = FMProgressHUD.hudForegroundColor
        flatSpinner.strokeThickness = FMProgressHUD.ringThickness
        flatSpinner.radius = FMProgressHUD.ringRadius
        flatSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        return flatSpinner
    }()
    
    private lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.accessibilityIdentifier = "FMProgressHUD_statusLabel"
        statusLabel.font = UIFont.systemFont(ofSize: FMProgressHUD.labelFontSize)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.textAlignment = .center
        statusLabel.baselineAdjustment = .alignCenters
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return statusLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var ringView: FMLoadingProgressView = {
        let ringView = FMLoadingProgressView()
        ringView.strokeColor = foregroundColorForStyle
        ringView.strokeThickness = FMProgressHUD.ringThickness
        ringView.radius = FMProgressHUD.ringRadius
        ringView.translatesAutoresizingMaskIntoConstraints = false
        
        return ringView
    }()
    
    private lazy var backgroundRingView: FMLoadingProgressView = {
        let backgroundRingView = FMLoadingProgressView()
        backgroundRingView.accessibilityIdentifier = "FMProgressHUD_progressView"
        backgroundRingView.strokeEnd = 1
        backgroundRingView.strokeColor = foregroundColorForStyle.withAlphaComponent(0.1)
        backgroundRingView.strokeThickness = FMProgressHUD.ringThickness
        backgroundRingView.radius = FMProgressHUD.ringRadius
        backgroundRingView.translatesAutoresizingMaskIntoConstraints = false
        backgroundRingView.addSubview(ringView)
        
        return backgroundRingView
    }()
    
    private lazy var hudView: UIVisualEffectView = {
        let blurEffectStyle = FMProgressHUD.hudStyle == .dark ? UIBlurEffect.Style.dark : UIBlurEffect.Style.light
        let blurEffect = UIBlurEffect(style: blurEffectStyle)
        let hudView = UIVisualEffectView(effect: blurEffect)
        hudView.accessibilityIdentifier = "FMProgressHUD_hudView"
        hudView.layer.masksToBounds = true
        hudView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.layer.cornerRadius = FMProgressHUD.cornerRadius
        hudView.alpha = 0
        hudView.isAccessibilityElement = true
        
        hudView.contentView.addSubview(stackView)
        let inset = FMProgressHUD.cornerRadius / 2
        hudView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: inset,
                                                                   leading: inset,
                                                                   bottom: inset,
                                                                   trailing: inset)
        let margins = hudView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: FMProgressHUD.HORIZONTAL_SPACING),
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -FMProgressHUD.HORIZONTAL_SPACING),
            stackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: FMProgressHUD.VERTICAL_SPACING),
            stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -FMProgressHUD.VERTICAL_SPACING),
        ])
        
        return hudView
    }()
    
    private lazy var backgroundView: FMTouchBlockingView = {
        let backgroundView = FMTouchBlockingView()
        backgroundView.accessibilityIdentifier = "FMProgressHUD_backgroundView"
        backgroundView.alpha = 0
        backgroundView.disableTouch = !FMProgressHUD.allowUserInteraction
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(hudView)
        NSLayoutConstraint.activate([
            hudView.centerYAnchor.constraint(equalTo: backgroundView.layoutMarginsGuide.centerYAnchor),
            hudView.centerXAnchor.constraint(equalTo: backgroundView.layoutMarginsGuide.centerXAnchor),
        ])
        
        return backgroundView
    }()
    
    // MARK: Private Vars
    
    private var imageView: UIImageView?
    private var fadeOutTimer: Timer?
    private var backgrounBottomConstraint: NSLayoutConstraint?
    
    private var backgroundColorForStyle: UIColor {
        switch FMProgressHUD.hudStyle {
        case .light:
            return .white
        case .dark:
            return .black
        default:
            return FMProgressHUD.hudBackgroundColor
        }
    }
    
    private var foregroundColorForStyle: UIColor {
        switch FMProgressHUD.hudStyle  {
        case .light:
            return .black
        case .dark:
            return .white
        default:
            return FMProgressHUD.hudForegroundColor
        }
    }
    
    
    private var spinner: UIView {
        FMProgressHUD.animationType == .flat ? flatSpinner : nativeSpinner
    }
    
    private var frontWindow: UIWindow? {
        let frontToBackWindows = UIApplication.shared.windows.reversed()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelSupported = window.windowLevel >= .normal && window.windowLevel <= UIWindow.Level.normal
            let windowIsKeyWindow = window.isKeyWindow
            if windowOnMainScreen && windowIsVisible && windowLevelSupported && windowIsKeyWindow {
                return window
            }
        }
        return nil
    }
    
    // MARK: Initializer
    
    init() {
        observeKeyboard()
        FMKeyboardStateListener.shared.observeKeyboard()
    }
    
    // MARK: Static methods
    
    /// Shows indefinite loading spinner HUD with optional status.
    /// Spinner is shown as either a ring spinner or native UIActivityIndicator, depending on the `animationType` value
    /// - parameters:
    ///     - status: optional status to show with the loading spinner. Default is nil
    public static func show(status: String? = nil) {
        FMProgressHUD.shared.show(status: status)
    }
    
    /// Shows image HUD with optional status.
    /// - parameters:
    ///     - progress: optional loading progress from 0 to 1
    ///     - status: optional status to show with the loading spinner. Default is nil
    public static func show(progress: CGFloat, status: String? = nil) {
        FMProgressHUD.shared.show(progress: progress, status: status)
    }
    
    /// Shows progress loading HUD with optional status.
    /// - parameters:
    ///     - image: image to show
    ///     - status: optional status to show with the loading spinner. Default is nil
    public static func show(image: UIImage, status: String? = nil) {
        FMProgressHUD.shared.show(image: image, status: status)
    }
    
    /// Show info HUD with SFSymbol's "info.circle"  icon
    /// - parameter status: optional status to show with the (i) symbol. Default is nil
    public static func showInfo(status: String? = nil) {
        guard let image = UIImage(systemName: "info.circle") else { return }
        FMProgressHUD.shared.show(image:image , status: status)
    }
    
    /// Show success HUD with SFSymbol's "checkmark"  icon
    /// - parameter status: optional status to show with the success tick. Default is nil
    public static func showSuccess(status: String? = nil) {
        guard let image = UIImage(systemName: "checkmark") else { return }
        FMProgressHUD.shared.show(image: image, status: status)
    }
    
    /// Show error HUD with SFSymbol's "xmark"  icon
    /// - parameter status: optional status to show with the X mark. Default is nil
    public static func showError(status: String? = nil) {
        guard let image = UIImage(systemName: "xmark") else { return }
        FMProgressHUD.shared.show(image: image, status: status)
    }
    
    /// Dismiss the HUD
    public static func dismiss() {
        FMProgressHUD.shared.dismiss()
    }
    
    // MARK: Instance methods
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            backgrounBottomConstraint?.constant = -keyboardFrame.height
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.backgroundView.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        backgrounBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.backgroundView.layoutIfNeeded()
        }
    }
    
    private func show(progress: CGFloat = -1, image: UIImage? = nil, status: String? = nil) {
        for view in self.stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        backgroundView.accessibilityViewIsModal = true
                
        // Add image
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.tintColor = foregroundColorForStyle
            imageView.accessibilityIdentifier = "FMProgressHUD_imageView"
            self.imageView = imageView
            stackView.addArrangedSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: FMProgressHUD.imageSize.height),
                imageView.widthAnchor.constraint(equalToConstant: FMProgressHUD.imageSize.width)
            ])
            
        // Add loading spinner or progress spinner
        } else {
            if progress >= 0 {
                stackView.addArrangedSubview(backgroundRingView)
                ringView.strokeEnd = progress
            } else {
                stackView.addArrangedSubview(spinner)
            }
        }
        
        // Add label
        if let status = status {
            statusLabel.text = status
            hudView.accessibilityLabel = status
            stackView.addArrangedSubview(statusLabel)
        }
        
        let duration = image == nil ? nil : TimeInterval(min(CGFloat((status ?? "").count) * 0.6 + 0.5, CGFloat.greatestFiniteMagnitude))
        addHudView(duration: duration)
    }
    
    @objc func dismiss() {
        self.fadeOutTimer?.invalidate()
        
        if backgroundView.superview != nil {
            let animationsBlock = { [weak self] in
                guard let self = self else { return }
                self.hudView.transform.scaledBy(x: 1 / 1.3, y: 1 / 1.3)
                self.fadeOutEffects()
            }
            let completionBlock = { [weak self] (_: Bool) in
                guard let self = self else { return }
                self.backgroundView.removeFromSuperview()
                for view in self.stackView.arrangedSubviews {
                    view.removeFromSuperview()
                }
                self.ringView.strokeEnd = -1
            }
            
            UIView.animate(withDuration: FMProgressHUD.fadeOutAnimationDuration,
                           delay: 0,
                           options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState],
                           animations: animationsBlock,
                           completion: completionBlock)
        }
    }
    
    private func addHudView(duration: TimeInterval?) {
        guard let frontWindow = frontWindow else { return }
        
        frontWindow.addSubview(backgroundView)
        backgrounBottomConstraint = backgroundView.bottomAnchor.constraint(equalTo: frontWindow.bottomAnchor)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: frontWindow.leadingAnchor),
            backgroundView.topAnchor.constraint(equalTo: frontWindow.topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: frontWindow.trailingAnchor),
            backgrounBottomConstraint!,
        ])
        
        // adjust bottom anchor to keyboard height if keyboard is shown
        if FMKeyboardStateListener.shared.keyboardIsVisible,
           let keyboardFrame = FMKeyboardStateListener.shared.keyboardFrame {
            backgrounBottomConstraint?.constant = -keyboardFrame.height
        }
        
        if backgroundView.alpha == 0 {
            hudView.alpha = 0
            for view in hudView.contentView.subviews {
                view.alpha = 0
            }
            
            hudView.transform = hudView.transform.scaledBy(x: 1.3, y: 1.3)
            let animationsBlock = { [weak self] in
                guard let self = self else { return }
                self.hudView.transform = CGAffineTransform.identity
                self.fadeInEffects()
            }
            let completionBlock = { [weak self] (_: Bool) in
                guard let self = self else { return }
                UIAccessibility.post(notification: .screenChanged, argument: nil)
                UIAccessibility.post(notification: .announcement, argument: self.statusLabel.text)
                if let duration = duration {
                    self.fadeOutTimer = Timer(timeInterval: duration, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
                    RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
                }
            }
            UIView.animate(withDuration: FMProgressHUD.fadeInAnimationDuration,
                           delay: 0,
                           options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState],
                           animations: animationsBlock,
                           completion: completionBlock)
        }
    }
    
    private func fadeInEffects() {
        backgroundView.alpha = 1
        hudView.alpha = 1
        for view in hudView.contentView.subviews {
            view.alpha = 1
        }
    }
    
    private func fadeOutEffects() {
        backgroundView.alpha = 0
        hudView.alpha = 0
        for view in hudView.contentView.subviews {
            view.alpha = 0
        }
    }

}
