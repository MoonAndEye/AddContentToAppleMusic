//
//  JSONKeys.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/26.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation


struct ResponseRootJSONKeys {
    static let data = "data"
    
    static let results = "results"
}

struct ResourceJSONKeys {
    static let identifier = "id"
    
    static let attributes = "attributes"
    
    static let type = "type"
}

struct ResourceTypeJSONKeys {
    static let songs = "songs"
    
    static let albums = "albums"
}
