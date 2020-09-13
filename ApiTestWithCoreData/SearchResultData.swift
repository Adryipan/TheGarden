//
//  SearchResultData.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class SearchResultData: NSObject, Decodable{
    var plants: [PlantData]?
    
    private enum CodingKeys: String, CodingKey{
        case plants = "data"
    }
}
