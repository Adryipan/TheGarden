//
//  AddExhibitionDelegate.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 15/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

protocol AddExhibitionDelegate: AnyObject {
    func addExhibitionDelegate(newExhibition: Exhibition) -> Bool
}
