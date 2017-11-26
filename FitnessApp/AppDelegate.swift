//
//  AppDelegate.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkUser {
            if(User.currentUser == nil){
                print("HUGE ERROR CANNT FIND OR CREATE USER")
            }else{
                print(User.currentUser)
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.checkUser {
            
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


extension AppDelegate{
    
    func checkUser(completion: @escaping ()->()){
        if User.currentUser == nil{
            User.getUser(userId: "user1", completion: { (user) in
                if let user = user{
                    let activitiesCount = User.currentUser.activities.count
                    print("FOUND USER : \(activitiesCount)")
//                    for item in User.currentUser.activities{
//                        print("\(item.duration) ======= Id: \(item.Id) , started: \(item.startDate),  ")
//                    }
//                    self.addFakePaths()
//                    completion()
                }else{
                    User.createUser(userId: "user1", completion: { (user) in
//                        self.addFakePaths()
                        completion()
                    })
                }
            })
        }
    }
    
    func addFakePaths(){
        //        return
        
        
        
        for item in User.currentUser.activities{
            var tempItem = item.Path[0]
            item.Path = [LocationData]()
            item.Path.append(tempItem)
            print("base was \(item.Path[0].longitude!) \(item.Path[0].latitude!)")
            for i in 0...10{
                let base = item.Path[0]
                let randomDistanceX = (Double(i*5) + Double(arc4random_uniform(5)) + (1.1/5.0))/1000
                let randomDistanceY = (Double(i*5) + Double(arc4random_uniform(5)) + (1.1/5.0))/1000
                item.Path.append(LocationData.createLocation(longitude: base.longitude+randomDistanceX
                    , latitude: base.latitude+randomDistanceY))
            }
        }
        User.save(user: User.currentUser) { (user) in
            for activity in User.currentUser.activities{
                for path in activity.Path{
                    print("\(path.time!) ===== \(path.latitude!) \(path.longitude!) ")
                }
                print("-----------------------------------------------------------------------")
            }
        }
    }
    
}



