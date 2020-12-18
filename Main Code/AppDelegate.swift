//
//  AppDelegate.swift
//  SideMenu
//
//  Created by jonkykong on 12/23/2015.
//  Copyright (c) 2015 jonkykong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //HERE TO PICK LAUNCHING SCREEN
        
        let logged: Bool? = AccountController.loadDataFromMemory()
        
        if let state = logged{
            if(state){
                // Download and then immidiately pass
                // Download
                print(logged ?? "nil")
                let model = AccountModel()
                model.delegate = self
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                
                let param = ["ios_app_ver": appVersion!, "email": AccountController.email!, "passhash": AccountController.password_hash!]
                model.downloadAccountData(parameters: param, url: URLServices.login)
                
                // Open main view
                openMainView()
                
                return true
            }
        }
        // If we do not have at least one type of data about account
        openLoginView()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //AccountController.saveDataToMemory()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //AccountController.saveDataToMemory()
    }
}

extension AppDelegate{
    func openMainView(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController: MainViewController = mainStoryboard.instantiateViewController(withIdentifier: "main") as! MainViewController

        self.window?.rootViewController = mainViewController

        self.window?.makeKeyAndVisible()
    }
    
    func openLoginView(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController: LoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "login") as! LoginViewController

        self.window?.rootViewController = loginViewController

        self.window?.makeKeyAndVisible()
    }
}

extension AppDelegate: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                print("not server")
                return
            }
            
            guard let account = data as? Account else{
                guard let error = data as? ServerError else{
                    print("not server2")
                    // This is literally impossible, but why not to leave it here)
                    return
                }
                
                // Server error
                if(error.code == 2){ // Invalid login/password
                    print("2 server")
                    openLoginView()
                }
                print("not 2 server")
                return
            }
            print("all is ok")
            AccountController.account = account
            AccountController.saveDataToMemory()
        }
    }
}

