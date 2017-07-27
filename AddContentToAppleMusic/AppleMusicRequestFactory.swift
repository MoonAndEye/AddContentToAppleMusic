//
//  AppleMusicRequestFactory.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/26.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation

struct AppleMusicRequestFactory {
    
    static let appleMusicAPIBaseURLString = "api.music.apple.com"
    
    static let recentlyPlayedPathURLString = "/v1/me/recent/played"
    
    static let userStorefrontPathURLString = "/v1/me/storefront"
 
    //送出 search request
    static func createSearchRequest(with term: String, countryCode: String, developerToken: String) -> URLRequest {
        
        let developerToken = devToken
        
        //把網址組合出來的方法
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/catalog/\(countryCode)/search"
        
        //第一行，應該是把空格換掉，第二行不知道是什麼意思，但 limit 應該是一回傳的筆數固定十筆
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["term": expectedTerms,
                             "limit": "10",
                             "types": "songs,albums"]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        urlComponents.queryItems = queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
        
    }
    
    static func createStorefrontsRequest(regionCode: String, developerToken: String) -> URLRequest {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/storefronts/\(regionCode)"
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }

}
