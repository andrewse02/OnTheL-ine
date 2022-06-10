//
//  QRCodeManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 6/9/22.
//

import Foundation
import UIKit

class QRCodeManager {
    static func generateQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
