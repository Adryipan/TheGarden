//
//  SceneDelegate.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var locationManager = CLLocationManager()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let splitViewController = window?.rootViewController as! UISplitViewController
        splitViewController.preferredDisplayMode = .allVisible
        
        let navigationController = splitViewController.viewControllers.first as! UINavigationController
        let locationTableViewController = navigationController.viewControllers.first as! AllExhibitionTableViewController
        let mapViewController = splitViewController.viewControllers.last as! MapViewController
        
        locationTableViewController.mapViewController = mapViewController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        (UIApplication.shared.delegate as? AppDelegate)?.databaseController?.cleanup()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func generateAlert(title: String, message: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        return alertController
    }
    

}

extension SceneDelegate: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if UIApplication.shared.applicationState == .active{
            // Show a popup on screen
            DisplayMessages.displayAlert(title: "Entering \(region.identifier)", message: "")
        }else{
            // Send a notification instead
            DisplayMessages.displayLocalNotification(body: "Welcome To \(region.identifier)", identifier: "Enter")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if UIApplication.shared.applicationState == .active{
            // Show a popup on screen
            DisplayMessages.displayAlert(title: "Exiting \(region.identifier)", message: "")
        }else{
            // Send a notification instead
            DisplayMessages.displayLocalNotification(body: "Good by from \(region.identifier)", identifier: "Exit")
        }
    }
}

