//
//  Downloaders.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 19/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

final class Downloader: NSObject{
        
    // MARK: - Setting up the URL session task
    private static func download(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()){
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    // MARK: - Data fetching functions
    public static func fetchImage(url: URL, completion: @escaping (Data?) -> Void){
        Downloader.download(url: url){(data, response, error) in
            
            // Fetching failed with an error
            if let _ = error{
                return
            }
            
            // Fetching succeeded but no data is returned
            guard let data = data, error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
            
        }
    }
    
}
