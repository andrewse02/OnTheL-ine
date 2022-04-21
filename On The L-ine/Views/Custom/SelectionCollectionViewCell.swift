//
//  SelectionCollectionViewCell.swift
//  SelectionTesting
//
//  Created by Andrew Elliott on 4/9/22.
//

import UIKit

typealias CellIndex = (row: Int, column: Int)

class SelectionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var type: BoardPiece?
    var index: CellIndex?
    var pieceSelected = false {
        didSet {
            updateViews()
        }
    }
    var overlay: UIView?
    
    // MARK: - Helper Functions
    
    func updateViews() {
        guard let type = type else { return }
        
        switch type {
        case .empty:
            self.backgroundColor = Colors.lightDark
            overlay?.removeFromSuperview()
            overlay = nil
        case .neutral:
            self.backgroundColor = pieceSelected ? Colors.green : Colors.lightDark
            self.overlay?.removeFromSuperview()
            
            let overlay = UIView(frame: CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.size.width * 0.75, height: self.frame.size.width * 0.75)))
            overlay.layer.cornerRadius = overlay.frame.size.height / 2
            overlay.backgroundColor = Colors.yellow
            
            overlay.center = CGPoint(x: self.frame.height / 2, y: self.frame.width / 2)
            
            self.addSubview(overlay)
            self.overlay = overlay
        case .player1, .player, .local:
            self.backgroundColor = Colors.primary
            overlay?.removeFromSuperview()
            overlay = nil
        case .player2, .computer, .online:
            self.backgroundColor = Colors.highlight
            overlay?.removeFromSuperview()
            overlay = nil
        }
    }
}
