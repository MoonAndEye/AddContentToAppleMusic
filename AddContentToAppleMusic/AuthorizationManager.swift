//
//  AppleMusicManager.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/26.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

@objc

class AuthorizationManager: NSObject {
    
    //或許這個是觀察者模式
    
    static let cloudServiceDidUpdateNotification = Notification.Name("cloudServiceDidUpdateNotification")
    
    static let authorizationDidUpdateNotification = Notification.Name("authorizationDidUpdateNotification")
    
    // 可能之後會在其他地方呼叫吧
    static let userTokenUserDefaultsKey = "UserTokenUserDefaultsKey"
    
    let cloudServiceController = SKCloudServiceController()
    
    let appleMusicManager: AppleMusicManager
    
    var cloudServiceCapabilities = SKCloudServiceCapability()
    
    var cloudServiceStorefrontCountryCode = ""
    
    //這功能現在沒有
    var userToken = ""
    
    //初始化
    init(appleMusicManager: AppleMusicManager) {
        self.appleMusicManager = appleMusicManager
        
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        /*
 
         監聽 SKCloudServiceCapabilitiesDidChangeNotification 和 SKStorefrontCountryCodeDidChangeNotification
         只要這兩個值一有變化，那 app 就可以知道
        */
        
        notificationCenter.addObserver(self, selector: #selector(requestCloudServiceCapabilities), name: .SKCloudServiceCapabilitiesDidChange, object: nil)
        
        if SKCloudServiceController.authorizationStatus() == .authorized {
            requestCloudServiceCapabilities()
        }
        
    }
    
    //移出觀察目標
    deinit {
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .SKCloudServiceCapabilitiesDidChange, object: nil)
    }
    
    func requestCloudServiceAuthorization() {
        
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else { return }
    
        SKCloudServiceController.requestAuthorization { [weak self] (authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                self?.requestCloudServiceAuthorization()
            default:
                break
            }
        }
    
    }
    
    func requestMediaLibraryAuthorization() {
        guard MPMediaLibrary.authorizationStatus() == .notDetermined else { return }
        
        MPMediaLibrary.requestAuthorization { (_) in
            NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
        }
    }
    
    func requestCloudServiceCapabilities() {
        
        cloudServiceController.requestCapabilities(completionHandler: { [weak self] (cloudServiceCapabilities, error) in
            guard error == nil else {
                fatalError("An error occurred when requesting capabilities: \(error!.localizedDescription)")
            }
            
            self?.cloudServiceCapabilities = cloudServiceCapabilities
            
            NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
        })
    }

    func requestStorefrontCountryCode() {
        let completionHandler: (String?, Error?) -> Void = { [weak self] (countryCode, error) in
            guard error == nil else {
                print("An error occurred when requesting storefront country code: \(error!.localizedDescription)")
                return
            }
            
            guard let countryCode = countryCode else {
                print("Unexpected value from SKCloudServiceController for storefront country code.")
                return
            }
            
            self?.cloudServiceStorefrontCountryCode = countryCode
            
            NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
        }
    }
    
    func determineRegionWithDeviceLocale(completion: @escaping (String?, Error?) -> Void) {
        
        let currentRegionCode = Locale.current.regionCode?.lowercased() ?? "us"
        
        appleMusicManager.performAppleMusicStorefrontsLookup(regionCode: currentRegionCode, completion: completion)
    }
}





