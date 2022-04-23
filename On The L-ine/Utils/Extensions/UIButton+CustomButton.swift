//
//  UIButton+CustomButton.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/23/22.
//

import Foundation
import UIKit

extension UIButton {
    
    func customButton(titleText: String, titleColor: UIColor?) {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: titleColor ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let buttonAttributes = NSMutableAttributedString(string: titleText, attributes: attributes)
        self.setAttributedTitle(buttonAttributes, for: .normal)
        self.layer.cornerRadius = self.frame.height / 4
    }
    
    func customOutlinedButton(titleText: String, titleColor: UIColor?, borderColor: UIColor?) {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "RalewayRoman-SemiBold", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: titleColor ?? UIColor()] as [NSAttributedString.Key : Any]
        
        let buttonAttributes = NSMutableAttributedString(string: titleText, attributes: attributes)
        self.setAttributedTitle(buttonAttributes, for: .normal)
        self.layer.cornerRadius = self.frame.height / 4
        
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor?.cgColor
    }
}
