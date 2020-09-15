//
//  Extensions.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 15/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    func loadImage(url: String){
        guard let imgURL = URL(string: url) else {
            return
        }
        
        if let imageInCache = imageCache.object(forKey: url as AnyObject){
            image = imageInCache as? UIImage
            return
        }
        
        ImageFetching.downloadImage(url: imgURL){ [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result{
            case .success(let data):
                guard let imageToBeCached = UIImage(data: data) else{
                    return
                }
                
                // Resize the image to 60x60 before caching
                let size = imageToBeCached.size
                let widthRatio = 60 / size.width
                let heightRatio = 60 / size.height
                
                // Determine the orientation of the image and hence the mode to resize
                var newSize: CGSize
                if(widthRatio > heightRatio){
                    newSize = CGSize(width: size.width * heightRatio, height:size.height * heightRatio)
                } else {
                    newSize = CGSize(width: size.width * widthRatio, height:size.height * widthRatio)
                }
                
                let rectangle = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
                
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                imageToBeCached.draw(in: rectangle)
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                imageCache.setObject(resizedImage!, forKey: url as AnyObject)
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.image = UIImage(named: "tree")
                }

            }
        }
        
    }
}
