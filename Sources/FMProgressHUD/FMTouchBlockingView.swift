//
//  FMTouchBlockingView.swift
//  fmHUDApp
//
//  Created by Matchima Ditthawibun on 15/5/21.
//

#if !os(macOS)
import UIKit
#endif

class FMTouchBlockingView: UIView {
    var disableTouch = false

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        disableTouch
    }
}
