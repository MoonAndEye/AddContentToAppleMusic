//
//  AppleMusicManager.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/26.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

@objc

class AuthorizationManager: NSObject {
    
    //或許這個是觀察者模式
    
    static let cloudServiceDidUpdateNotification = Notification.Name("cloudServiceDidUpdateNotification")
    
    static let authorizationDidUpdateNotification = Notification.Name("authorizationDidUpdateNotification")

    // 可能之後會在其他地方呼叫吧
    static let userTokenUserDefaultsKey = "UserTokenUserDefaultsKey"
    
    let cloudServiceController = SKCloudServiceController()
    
    var cloudServiceCapabilities = SKCloudServiceCapability()
    
    var cloudServiceStorefrontCountryCode = ""
    
    var userToken = ""
}
