//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/10/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //setting the app theme color so the alert text shows up as orange
        window?.tintColor = UIColor.orange
        
        return true
    }
}

