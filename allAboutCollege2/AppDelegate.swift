//
//  AppDelegate.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/18/23.
//

import UIKit
import FirebaseCore
import Firebase
import GoogleSignIn
import RealmSwift
import SwiftCSV

var databasePointer:OpaquePointer?
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        
        let config1 = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "Course", withExtension: "realm"), readOnly: true, schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
            })
        Realm.Configuration.defaultConfiguration = config1
        
        
        do {
            let realm = try Realm()
            
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        if let dbPointer = DBHelper.getDatabasePointer(databaseName: "UIUCGradeDistribution.db"){
            databasePointer=dbPointer
        }
        else{
            
        }
        
        
       
        
 
      
        
        
        
        
        
        return true
    }
    
        
        func application(_ app: UIApplication,
                         open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
            
            return GIDSignIn.sharedInstance().handle(url)
        }
        
        // MARK: UISceneSession Lifecycle
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
        
        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
            // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        }
        
        
}


    
    
    
   
