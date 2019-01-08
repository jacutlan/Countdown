//
//  UIImage+Insets.swift
//  Countdown
//
//  Created by Josh Cutlan on 3/1/19.
//  Copyright © 2019 Josh Cutlan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func imageWithInsets(insetDimension: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimension, left: insetDimension, bottom: insetDimension, right: insetDimension))
    }
    
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width + insets.left + insets.right, height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
}
