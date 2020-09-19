//
//  DisplayMessages.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 19/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class DisplayMessages{
    
    static func displayAlert(title: String, message: String){
        if let window = UIApplication.shared.windows.first{
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            window.rootViewController!.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func displayLocalNotification(body: String, identifier: String){
        let content = UNMutableNotificationContent()
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ error in
            if let error = error{
                print(error)
            }
        }
    }
}
