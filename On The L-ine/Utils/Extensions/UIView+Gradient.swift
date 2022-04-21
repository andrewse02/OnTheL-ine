//
//  UIView+Gradient.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/21/22.
//

import Foundation
import UIKit

extension UIView {
    func verticalGradient(top: UIColor? = Colors.primaryDark, bottom: UIColor? = Colors.primaryMiddleDark) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            bottom?.cgColor ?? UIColor().cgColor,
            top?.cgColor ?? UIColor().cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0.8)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.2)
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func horizontalGradient(left: UIColor? = Colors.primary, right: UIColor? = Colors.primaryLight) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            right?.cgColor ?? UIColor().cgColor,
            left?.cgColor ?? UIColor().cgColor
        ]
        
        gradient.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        gradient.frame = bounds
        
        layer.insertSublayer(gradient, at: 1)
    }
}
