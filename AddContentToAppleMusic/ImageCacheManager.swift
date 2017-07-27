//
//  ImageCacheManager.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/27.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import UIKit

class ImageCacheManager {
    
    static let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        
        cache.name = "ImageCacheManager"
        
        //把上限設定在 20 張圖片
        cache.countLimit = 20
        
        //把容量設定在 10 MB
        cache.totalCostLimit = 10 * 1024 * 1024
        
        return cache
    }()
    
    func cachedImage(url: URL) -> UIImage? {
        return ImageCacheManager.imageCache.object(forKey: url.absoluteString as NSString)
    }
    
    func fetchImage(url: URL, completion: @escaping ((UIImage?) -> Void )) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            
            if let image = UIImage(data: data) {
                
                ImageCacheManager.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
            }
        }
        
        task.resume()
        
    }
    
}
