//
//  ImageSearchResultData.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 19/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class ImageSearchResultData: NSObject, Decodable{
    var images: [ImageData]?
    
    private enum CodingKeys: String, CodingKey{
        case images = "hits"
    }
}
