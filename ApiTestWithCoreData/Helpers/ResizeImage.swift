//
//  ResizeImage.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 17/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ResizeImage: NSObject{
    
    static func resizeImage(image: UIImage, width: Int, height: Int) -> UIImage{
        // Resize the image to 60x60 before caching
        let size = image.size
        let widthRatio = CGFloat(width) / size.width
        let heightRatio = CGFloat(height) / size.height
        
        // Determine the orientation of the image and hence the mode to resize
        var newSize: CGSize
        if(widthRatio > heightRatio){
            newSize = CGSize(width: size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height:size.height * widthRatio)
        }
        
        let rectangle = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rectangle)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}
