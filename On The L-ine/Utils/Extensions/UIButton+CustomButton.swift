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
        
        self.layer.borderWidth = 0
        self.layer.borderColor = .none
        
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
        
        self.backgroundColor = .none
    }
    
    func customTextButton(titleText: String, titleColor: UIColor?) {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: titleColor ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let buttonAttributes = NSMutableAttributedString(string: titleText, attributes: attributes)
        self.setAttributedTitle(buttonAttributes, for: .normal)
        self.layer.cornerRadius = self.frame.height / 4
    }
    
    // Unused, remove function crashes
    func addUnderline(underline: CALayer) {
        let size = CGSize(width: self.frame.width * 0.6, height: 3)
        
        underline.backgroundColor = Colors.light?.cgColor
        underline.frame = CGRect(origin: CGPoint(x: (self.frame.width / 2) - (size.width / 2), y: self.frame.height - size.height), size: size)
        
        self.layer.addSublayer(underline)
    }
}
