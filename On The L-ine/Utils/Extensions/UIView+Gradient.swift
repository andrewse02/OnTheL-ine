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
            top?.cgColor ?? UIColor().cgColor,
            bottom?.cgColor ?? UIColor().cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0.2)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.8)
        
        if let foundLayer = self.layer.sublayers?[0] as? CAGradientLayer { foundLayer.removeFromSuperlayer() }
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func horizontalGradient(left: UIColor? = Colors.primary, right: UIColor? = Colors.primaryLight) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            left?.cgColor ?? UIColor().cgColor,
            right?.cgColor ?? UIColor().cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.2, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.8, y: 0.5)
        
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
    
    func textGradient(left: UIColor?, right: UIColor?) {
        let gradient = getGradientLayer(left: left, right: right)
        guard let self = self as? UILabel else { return }
        
        self.textColor = gradientColor(gradientLayer: gradient)
    }
    
    private func gradientColor(gradientLayer: CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
    
    private func getGradientLayer(left: UIColor?, right: UIColor?) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = bounds.insetBy(dx: -5, dy: 0)
        gradient.colors = [
            left?.cgColor ?? UIColor().cgColor,
            right?.cgColor ?? UIColor().cgColor
        ]
        
        gradient.startPoint = CGPoint(x: -0.1, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.8, y: 0.5)
        
        return gradient
    }
}
