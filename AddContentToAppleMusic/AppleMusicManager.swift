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
        
        let urlSessionConfiguration = URLSessionConfiguration.default
        
        return URLSession(configuration: urlSessionConfiguration)
    }()
    
    var storefrontID: String?
    
    
    
    func fetchDeeveloperToken() -> String? {
        
        let developerAuthenticationToken: String? = nil
        
        return developerAuthenticationToken
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        
        //這應該可以先註解掉，之後再玩網路傳 token
//        guard let developerToken = fetchDeeveloperToken() else {
//            fatalError(" 你的 Developer token 還沒準備好")
//        }
        
        let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, developerToken: devToken)
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse,
                urlResponse.statusCode == 200 else {
                    completion([], error)
                return
            }
            
            do {
                let mediaItems = try self.processMediaItemSections(from: data!)
                completion(mediaItems, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
            
        }
        
        task.resume()
    }
    
    func processMediaItemSections(from json: Data) throws -> [[MediaItem]] {
        
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String:[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        var mediaItems = [[MediaItem]]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(songMediaItems)
            }
        }
        
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
                
            }
        }
        
        return mediaItems
    }
    
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processStorefront(from json: Data) throws -> String {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        guard let identifier = data.first?[ResourceJSONKeys.identifier] as? String else {
            throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        return identifier
    }
    
}

