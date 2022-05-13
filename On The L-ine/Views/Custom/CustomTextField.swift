//
//  CustomTextField.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/26/22.
//

import UIKit

class CustomTextField: UITextField {
    private let paddingInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.height / 4
        
        self.layer.borderColor = Colors.lightDark?.cgColor
        self.layer.borderWidth = 2
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: Colors.lightDark ?? UIColor()])
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: paddingInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: paddingInsets)
    }

}
