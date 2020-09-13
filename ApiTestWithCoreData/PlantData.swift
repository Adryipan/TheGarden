//
//  PlantData.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class PlantData: NSObject, Decodable{
    var commonName: String?
    var scienceName: String?
    var family: String?
    var yearDiscovered: Int?
    var image_url: String?
    
    private enum RootKeys: String, CodingKey{
        case commonName = "common_name"
        case scienceName = "scientific_name"
        case family
        case yearDiscovered = "year"
        case image_url
    }
    
    required init(from decoder: Decoder) throws{
        let plantContainer = try decoder.container(keyedBy: RootKeys.self)
        
        commonName = try plantContainer.decode(String?.self, forKey: .commonName)
        scienceName = try plantContainer.decode(String.self, forKey: .scienceName)
        family = try plantContainer.decode(String.self, forKey: .family)
        yearDiscovered = try plantContainer.decode(Int.self, forKey: .yearDiscovered)
        image_url = try plantContainer.decode(String?.self, forKey: .image_url)
    }
}
