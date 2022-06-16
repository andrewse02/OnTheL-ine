//
//  Bundle+VersionNumber.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 6/16/22.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var releaseVersionNumberPretty: String {
        guard let releaseVersionNumber = releaseVersionNumber,
              let buildVersionNumber = buildVersionNumber else { return "" }

        return "\(releaseVersionNumber)\(buildVersionNumber == "1" ? "" : "b\(buildVersionNumber)")"
    }
}
