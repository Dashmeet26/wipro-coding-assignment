//
//  AppDelegate.swift
//  CodingAssignment
//
//  Created by FT User on 14/10/20.
//  Copyright © 2020 FT User. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navController = UINavigationController()
        let homeVc = HomeViewController()
        navController.viewControllers = [homeVc]
        homeVc.view.backgroundColor = UIColor.white
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    
}

