//
//  KeyboardStateListener.swift
//  fmHUDApp
//
//  Created by Matchima Ditthawibun on 15/5/21.
//

#if !os(macOS)
import UIKit
#endif

class FMKeyboardStateListener {
    
    static var shared = FMKeyboardStateListener()
    var keyboardIsVisible = false
    var keyboardFrame: CGRect?
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardIsVisible = true
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.keyboardFrame = keyboardFrame
        }
    }
    
    @objc func keyboardDidHide() {
        keyboardIsVisible = false
        keyboardFrame = nil
    }
}
