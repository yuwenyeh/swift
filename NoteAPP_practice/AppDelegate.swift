//
//  AppDelegate.swift
//  NoteAPP_practice
//
//  Created by 郭子毅 on 2020/5/11.
//  Copyright © 2020 郭子毅. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("\(NSHomeDirectory())")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        print("1234")
         print("\(NSHomeDirectory())")
        FirebaseApp.configure()
        return true
    }


}

