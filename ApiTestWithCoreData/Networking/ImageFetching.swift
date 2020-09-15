//
//  ImageFetching.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 15/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

public enum Result<T>{
    case success(T)
    case failure(Error)
}

final class ImageFetching: NSObject{
    
    private static func getData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) ->()){
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    public static func downloadImage(url: URL, completion: @escaping (Result<Data>) -> Void){
        
        ImageFetching.getData(url: url){ (data, response, error) in
            if let error = error{
                completion(.failure(error))
            }
            
            guard let data = data, error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
    }
}
