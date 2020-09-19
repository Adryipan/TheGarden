//
//  Extensions.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 19/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

// MARK: - Extension for UIImageView
extension UIImageView{
    func loadIcon(urlString: String){
        guard let imageURL = URL(string: urlString) else { return }
        
        image = nil
        
        // If the image is found in the cache, return the image
        if let imageInCache = imageCache.object(forKey: urlString as NSString){
            image = ResizeImage.resizeImageByViewDimension(image: imageInCache, width: self.bounds.width, height: self.bounds.height)
            return
        }
        
        // If the image is not found in cache, download it and cache it
        
        Downloader.fetchImage(url: imageURL){ [weak self] data in
            guard let self = self else { return }
            guard var imageToCache = UIImage(data: data!) else {
                self.image = ResizeImage.resizeImageByViewDimension(image: UIImage(named: "tree")!, width: self.bounds.width, height: self.bounds.height) 
                return
            }
            
            imageCache.setObject(imageToCache, forKey: urlString as NSString)
            imageToCache = ResizeImage.resizeImageByViewDimension(image: imageToCache, width: self.bounds.width, height: self.bounds.height)
            self.image = imageToCache
        }
    }
}
