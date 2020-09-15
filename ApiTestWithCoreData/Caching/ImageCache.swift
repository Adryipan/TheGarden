//
//  ImageCache.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 16/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import UIKit
public class ImageCache{
    
    public static let publicCache = ImageCache()
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(UIImage?) -> Swift.Void]]()
    
    public final func image(url: NSURL) -> UIImage?{
        return cachedImages.object(forKey: url)
    }
    
    final func load(url: NSURL, completion: @escaping (UIImage?) -> Swift.Void) {
        if let cachedImage = image(url: url){
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // This is to handle multiple load request, append the completion block and queue
        if loadingResponses[url] != nil{
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        
        ImageFetching.downloadImage(url: <#T##URL#>, completion: <#T##(Result<Data>) -> Void#>)
    }
    
}
