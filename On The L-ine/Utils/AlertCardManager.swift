//
//  CardManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 6/16/22.
//

import Foundation
import BLTNBoard

class AlertCardManager {
    static var manager: BLTNItemManager? {
        didSet {
            guard let manager = manager else { return }
            manager.backgroundColor = Colors.light ?? UIColor()
        }
    }
    
    static let changelogDescription = ""
    
    static let tutorialDescription = """
    To get started, it's recommended that you get a feel for how the game works with the tutorial.
    """
    
    static let deleteDescription = "Are you sure you want to delete your acount? This process cannot be undone."
    
    static var changelog: BLTNItemManager = {
        let rootItem = BLTNPageItem(title: "What's new in\nv\(Bundle.main.releaseVersionNumberPretty)?")
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 100)
        rootItem.image = UIImage(systemName: "icloud.and.arrow.down", withConfiguration: symbolConfig)
        rootItem.descriptionText = changelogDescription
        rootItem.actionButtonTitle = "Ok"
        
        rootItem.appearance.titleFontDescriptor = UIFontDescriptor(name: "RalewayRoman-SemiBold", size: 32)
        rootItem.appearance.titleTextColor = Colors.dark ?? UIColor()
        
        rootItem.appearance.imageViewTintColor = Colors.primary ?? UIColor()
        
        rootItem.appearance.descriptionFontDescriptor = UIFontDescriptor(name: "RalewayRoman-Medium", size: 16)
        rootItem.appearance.descriptionTextColor = Colors.dark ?? UIColor()
        rootItem.appearance.descriptionTextAlignment = .left
        
        rootItem.appearance.actionButtonColor = Colors.primary ?? UIColor()
        rootItem.appearance.actionButtonFontSize = 20
        rootItem.appearance.actionButtonTitleColor = Colors.light ?? UIColor()
        
        rootItem.actionHandler = { (item: BLTNActionItem) in
            item.manager?.dismissBulletin()
        }
        
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.backgroundColor = Colors.light ?? UIColor()
        
        return manager
    }()
    
    static func tutorial(action: @escaping (BLTNActionItem) -> Void) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Welcome to\nOn The L-ine!")
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 100)
        rootItem.image = UIImage(systemName: "hand.wave", withConfiguration: symbolConfig)
        rootItem.descriptionText = tutorialDescription
        rootItem.actionButtonTitle = "Start"
        rootItem.alternativeButtonTitle = "Skip Tutorial"
        
        rootItem.appearance.titleFontDescriptor = UIFontDescriptor(name: "RalewayRoman-SemiBold", size: 32)
        rootItem.appearance.titleTextColor = Colors.dark ?? UIColor()
        
        rootItem.appearance.imageViewTintColor = Colors.primary ?? UIColor()
        
        rootItem.appearance.descriptionFontDescriptor = UIFontDescriptor(name: "RalewayRoman-Medium", size: 16)
        rootItem.appearance.descriptionTextColor = Colors.dark ?? UIColor()
        
        rootItem.appearance.actionButtonFontSize = 20
        rootItem.appearance.actionButtonColor = Colors.primary ?? UIColor()
        rootItem.appearance.actionButtonTitleColor = Colors.light ?? UIColor()
        
        rootItem.appearance.alternativeButtonFontSize = 16
        rootItem.appearance.alternativeButtonTitleColor = Colors.primary ?? UIColor()
        
        
        rootItem.actionHandler = action
        rootItem.alternativeHandler = { (item: BLTNActionItem) in
            item.manager?.dismissBulletin()
        }
        
        rootItem.isDismissable = false
        
        return rootItem
    }
    
    static func deleteAccount(action: @escaping (BLTNActionItem) -> Void) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Delete Account?")
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 100)
        rootItem.image = UIImage(systemName: "x.circle.fill", withConfiguration: symbolConfig)
        rootItem.descriptionText = deleteDescription
        rootItem.actionButtonTitle = "Cancel"
        rootItem.alternativeButtonTitle = "Delete Account"
        
        rootItem.appearance.titleFontDescriptor = UIFontDescriptor(name: "RalewayRoman-SemiBold", size: 32)
        rootItem.appearance.titleTextColor = Colors.dark ?? UIColor()
        
        rootItem.appearance.imageViewTintColor = Colors.highlight ?? UIColor()
        
        rootItem.appearance.descriptionFontDescriptor = UIFontDescriptor(name: "RalewayRoman-Medium", size: 16)
        rootItem.appearance.descriptionTextColor = Colors.highlight ?? UIColor()
        
        rootItem.appearance.actionButtonFontSize = 20
        rootItem.appearance.actionButtonColor = Colors.middleDark ?? UIColor()
        rootItem.appearance.actionButtonTitleColor = Colors.light ?? UIColor()
        
        rootItem.appearance.alternativeButtonFontSize = 16
        rootItem.appearance.alternativeButtonTitleColor = Colors.highlight ?? UIColor()
        
        
        rootItem.alternativeHandler = action
        rootItem.actionHandler = { (item: BLTNActionItem) in
            item.manager?.dismissBulletin()
        }
        
        rootItem.isDismissable = false
        
        return rootItem
    }
}
