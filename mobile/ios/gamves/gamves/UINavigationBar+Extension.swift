//
//  UINavigationBar+Extension.swift
//  gamves
//
//  Created by Jose Vigil on 10/22/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit

private var AssociatedObjectHandle: UInt8 = 0

extension UINavigationBar {
    
    var height: CGFloat {
        get {
            if let h = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? CGFloat {
                return h
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        if self.height > 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: self.height)
        }
        return super.sizeThatFits(size)
    }
    
}
