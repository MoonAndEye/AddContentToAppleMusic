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

class AppleMusicManager {
    
    //下面這些宣告，可以節省程式碼的複雜度
    typealias CatalogSearchCompletionHandler = (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void
    
    typealias GetUserStorefrontCompletionHandler = (_ storefront: String?, _ error: Error?) -> Void
    
    typealias GetRecentlyPlayedCompletionHandler = (_ mediaItems: [MediaItem], _ error: Error?) -> Void

    lazy var urlSession: URLSession = {
        
        let urlSessionConfiguration = urlSessionConfiguration.default
        
        return URLSession(configuration: urlSessionConfiguration)
    }()
    
    var storefrontID: String?
    
    
    
    func fetchDeeveloperToken() -> String? {
        
        let developerAuthenticationToken: String? = nil
        
        return developerAuthenticationToken
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        
        guard let developerToken = fetchDeeveloperToken() else {
            fatalError(" 你的 Developer token 還沒準備好")
        }
        
        let urlRequest = AppleMus
    }
}
