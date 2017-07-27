//
//  SerializationError.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/26.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    
    /// This case indicates that the expected field in the JSON object is not found.
    case missing(String)
}
