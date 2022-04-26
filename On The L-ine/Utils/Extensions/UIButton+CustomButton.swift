//
//  UIButton+CustomButton.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/23/22.
//

import Foundation
import UIKit

extension UIButton {
    
    func customButton(titleText: String, titleColor: UIColor?, backgroundColor: UIColor? = nil) {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: titleColor ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let buttonAttributes = NSMutableAttributedString(string: titleText, attributes: attributes)
        self.setAttributedTitle(buttonAttributes, for: .normal)
        self.layer.cornerRadius = self.frame.height / 4
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
    }
    
    func customOutlinedButton(titleText: String, titleColor: UIColor?, borderColor: UIColor?) {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: titleColor ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let buttonAttributes = NSMutableAttributedString(string: titleText, attributes: attributes)
        self.setAttributedTitle(buttonAttributes, for: .normal)
        self.layer.cornerRadius = self.frame.height / 4
        
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor?.cgColor
    }
    
    func customTextButton(titleText: String, titleColor: UIColor?) {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: titleColor ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let buttonAttributes = NSMutableAttributedString(string: titleText, attributes: attributes)
        self.setAttributedTitle(buttonAttributes, for: .normal)
        self.layer.cornerRadius = self.frame.height / 4
    }
    
    // Unused, remove function crashes
    func addUnderline() {
        let underline = CALayer()
        underline.backgroundColor = Colors.light?.cgColor
        underline.frame = CGRect(origin: CGPoint(x: 0, y: 40), size: CGSize(width: self.frame.width * 0.8, height: 3))
        
        self.layer.addSublayer(underline)
        for sublayer in self.layer.sublayers ?? [] {
            print(sublayer.bounds)
        }
    }
}
