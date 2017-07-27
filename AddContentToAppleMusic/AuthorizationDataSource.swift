//
//  AuthorizationDataSource.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/27.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import MediaPlayer

class AuthorizationDataSource {
    
    enum SectionTypes: Int {
        case mediaLibraryAuthorizationStatus = 0, cloudServiceAuthorizationStatus, requestCapabilities
        
        func sectionTitle() -> String {
            switch self {
            case .cloudServiceAuthorizationStatus:
                return "SKCloudServiceController"
            case .requestCapabilities:
                return "Capabilities"
            case .mediaLibraryAuthorizationStatus:
                return "MPMediaLibrary"
            }
        }
    }
    
    let authorizationManager: AuthorizationManager
    
    var capabilities = [SKCloudServiceCapability]()
    
    init(authorizationManager: AuthorizationManager) {
        self.authorizationManager = authorizationManager
    }
    
    public func numberOfSections() -> Int {
        
        //總是要有地方要放 authorizationStatus 給`SKCloudServiceController` and `MPMediaLibrary`.
        var section = 2
        
        //如果有權限看 CloudService
        if SKCloudServiceController.authorizationStatus() == .authorized {
            
            let cloudServiceCapabilities = authorizationManager.cloudServiceCapabilities
            
            capabilities = []
            
            if cloudServiceCapabilities.contains(.addToCloudMusicLibrary) {
                capabilities.append(.addToCloudMusicLibrary)
            }
            
            if cloudServiceCapabilities.contains(.musicCatalogPlayback) {
                capabilities.append(.musicCatalogPlayback)
            }
            
            if cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible) {
                capabilities.append(.musicCatalogSubscriptionEligible)
            }
            
            section += 1
        }
        
        return section
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sectionType = SectionTypes(rawValue: section) else {
            return 0
        }
        
        switch sectionType {
        case .cloudServiceAuthorizationStatus:
            return 1
        case .requestCapabilities:
            return capabilities.count
        case .mediaLibraryAuthorizationStatus:
            return 1
        }
    }
    
    public func sectionTitle(for section: Int) -> String {
        guard let sectionType = SectionTypes(rawValue: section) else {
            return ""
        }
        
        return sectionType.sectionTitle()
    }
    
    public func stringForItem(at indexPath: IndexPath) -> String {
        guard let sectionType = SectionTypes(rawValue: indexPath.section) else {
            return ""
        }
        
        switch sectionType {
        case .cloudServiceAuthorizationStatus:
            return SKCloudServiceController.authorizationStatus().statusString()
        case .requestCapabilities:
            return capabilities[indexPath.row].capabilityString()
        case .mediaLibraryAuthorizationStatus:
            return MPMediaLibrary.authorizationStatus().statusString()
        }
        
    }
    
}

extension SKCloudServiceAuthorizationStatus {
    func statusString() -> String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorized:
            return "Authorized"
        }
    }
}

extension MPMediaLibraryAuthorizationStatus {
    func statusString() -> String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorized:
            return "Authorized"
        }
    }
}

extension SKCloudServiceCapability {
    func capabilityString() -> String {
        switch self {
        case SKCloudServiceCapability.addToCloudMusicLibrary:
            return "Add To Cloud Music Library"
        case SKCloudServiceCapability.musicCatalogPlayback:
            return "Music Catalog Playback"
        case SKCloudServiceCapability.musicCatalogSubscriptionEligible:
            return "Music Catalog Subscription Eligible"
        default:
            return ""
        }
    }
}
