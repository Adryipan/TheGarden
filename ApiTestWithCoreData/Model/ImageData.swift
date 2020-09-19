//
//  ImageData.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 19/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class ImageData: NSObject, Decodable{
    var image_url: String
    
    private enum CodingKeys: String, CodingKey{
        case image_url = "previewURL"
    }
}
