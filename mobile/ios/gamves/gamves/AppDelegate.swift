//
//  AppDelegate.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit
import Parse
import UserNotifications
import DeviceKit

import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var delegateFeed:FeedDelegate!
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    var inBackground = Bool()
    
    var gamvesApplication:UIApplication?
    
    var homeController:HomeController!
    
    var online = Bool()
    var connect = Bool()
    
    var userDefault = UserDefaults(suiteName: "group.com.gamves.share")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            os_log("HOLA")
        } else {
            // Fallback on earlier versions
        }
        
        var username = userDefault.string(forKey: "gamves_shared_extension_user")
        var password = userDefault.string(forKey: "gamves_shared_extension_password")

        //Shared group extension
        Global.appGroupDefaults = UserDefaults(suiteName: Global.groupShare)!
        
        Global.forceFromNetworkCache = true
        
        let deviceobj = Device()
        let device:String = "\(deviceobj)"
        Global.device = device
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        homeController = HomeController(collectionViewLayout: layout)
        
        var reached = false
        
        //connect = true
        //if connect {
            
        //Uncomment
        if Reachability.isConnectedToNetwork() {
            
            online = true
            
            loadParse(application: application, launchOptions: launchOptions)
            print("Internet connection OK")
            
            reached = true
            
            UINavigationBar.appearance().barTintColor = UIColor.gamvesColor
            
            application.statusBarStyle = .lightContent
            
            // get rid of black bar underneath navbar
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)            
                        
            DispatchQueue.main.async {
                Global.loadAditionalData()
            }
            
            if let user = PFUser.current() {
                
                window?.rootViewController = UINavigationController(rootViewController: homeController)

                if let userId = PFUser.current()?.objectId {

                    Global.getYourUserData(id:userId, completionHandler: { ( result:Bool ) -> () in

                        if result {

                            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyYourUserDataLoaded), object: self)

                        } else {
                            
                            print("Level not loading")
                        }
                
                    })
                }
                
            } else {
                
                window?.rootViewController = UINavigationController(rootViewController: LoginController())
                
            }
            
            //print(PFUser.current()?.username)
            
            let statusBarBackgroundView = UIView()
            statusBarBackgroundView.backgroundColor = UIColor.gamvesBlackColor
            
            window?.addSubview(statusBarBackgroundView)
            window?.addConstraintsWithFormat("H:|[v0]|", views: statusBarBackgroundView)
            window?.addConstraintsWithFormat("V:|[v0(20)]", views: statusBarBackgroundView)
            
            if #available(iOS 10.0, *)
            {
                let center = UNUserNotificationCenter.current()
                center.delegate = self
                center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                    
                    if error == nil {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                
            } else {
                
                if #available(iOS 7, *)
                {
                    //application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
                    registerApplicationForPushNotifications(application: application)
                } else {
                    
                    let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
                    
                    let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                    
                    UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            
        } else {
            
           var noConnectionViewController:NoConnectionViewController!

           noConnectionViewController = NoConnectionViewController()
            
           window?.rootViewController = noConnectionViewController      
            
           UITabBar.appearance().barTintColor = UIColor.gamvesColor
           UITabBar.appearance().tintColor = UIColor.white 
            
        }
        
        return true
        
    }
    
    func registerApplicationForPushNotifications(application: UIApplication) {
        // Set up push notifications
        // For more information about Push, check out:
        // https://developer.layer.com/docs/guides/ios#push-notification
        
        // Register device for iOS8
        //let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: UIUserNotificationType.badge, categories: nil)
        
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }

    
    func loadParse(application: UIApplication, launchOptions: [AnyHashable: Any]?)
    {
        Parse.enableLocalDatastore()
        
        //Local
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "0123456789"
            $0.server = Global.serverUrl
        }
        Parse.initialize(with: configuration)*/

        //Back4app
        let configuration = ParseClientConfiguration {
            $0.applicationId = "45cgsAjYqwQQRctQTluoUpVvKsHqrjCmvh72UGBx"
            $0.clientKey = "FNRCkl1ou1wjX4j8uzhnavxNAna2OH8pjmTYPvvF"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        //Sashido
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "lTEkncCXc0jS7cyEAZwAr2IYdABenRsY86KPhzJT"
            $0.clientKey = "sMlMuxDQTs631WYXfS5rdnUQzeeRPB6JFNnKsVhY"
            $0.server = "https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
        }
        Parse.initialize(with: configuration)*/
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        

        //Notifications
        /*let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()*/
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    @objc(application:didRegisterForRemoteNotificationsWithDeviceToken:) func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        
        let deviceobj = Device()
        let device:String = "\(deviceobj)"
        installation?["device"] = device
        
        installation?.saveInBackground()
    
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let data = userInfo["data"] as? [String:Any] {
            let message = data["message"]
            print(message)
            let chatId = data["chatId"]
            print(chatId)
        }
        
        if let title = userInfo["title"] as? [String:Any]
        {
            print(title)
        }
        
        self.gamvesApplication = application
        
        if online && PFUser.current() != nil {
        
            Global.loadBargesNumberForUser(completionHandler: { ( badgeNumber ) -> () in
            
                self.gamvesApplication?.applicationIconBadgeNumber = badgeNumber
                
            })

            ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })
        }
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        /*self.inBackground = true
        if online && PFUser.current() != nil {
            Global.updateUserOnline(online: false, idle: false)
        }*/
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.inBackground = true
        if online && PFUser.current() != nil {
            Global.updateUserStatus(status: 1)
        }
        
    }
  
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        self.inBackground = true
        
        if online && PFUser.current() != nil {
            Global.updateUserStatus(status: 1)
        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.inBackground = false
        
        self.gamvesApplication = application
        
        if online && PFUser.current() != nil {
        
            Global.loadBargesNumberForUser(completionHandler: { ( badgeNumber ) -> () in

                print(badgeNumber)
                self.gamvesApplication?.applicationIconBadgeNumber = badgeNumber
            
            })
            
            Global.updateUserStatus(status: 2)
            
        }
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.inBackground = true
        
        if online && PFUser.current() != nil {
            Global.updateUserStatus(status: 0)
        }

    }
    
    func openSearch(params:[String : Any]) {        
        self.homeController.openSearch(params:params)
    } 
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == "gamves"
        {
            //TODO: Write your code here
        }
        
        print("url.scheme - \(url.scheme)")
        print("url.absoluteString - \(url.absoluteString)")
        print("url.absoluteURL - \(url.absoluteURL)")
        print("url.description - \(url.description)")
        print("url.debugDescription - \(url.debugDescription)")
        
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        let param1 = queryItems?.filter({$0.name == "myParam"}).first
        
        if let temp = param1 {
            
            // we first unwrap param1, when its valid, we can use it to access its property value
            // value is optional itself, i decided to use force unwrap here
            /*let topWindow = UIWindow(frame: UIScreen.main.bounds)
            topWindow.rootViewController = UIViewController()
            topWindow.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "APNS", message: "received Notification -  \(temp.value!)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                // continue your work
                // important to hide the window after work completed.
                // this also keeps a reference to the window until the action is invoked.
                topWindow.isHidden = true
            }))
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.present(alert, animated: true, completion: { _ in })*/
            
        }
        return true
    }
    
    
}

