//
//  AppDelegate.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 21/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKLoginKit
import GoogleSignIn
import SwiftyGif
import AVFoundation
import SDWebImage
import OneSignal
import SwiftEventBus
import SwiftyBeaver
import PixelPhotoFramework
import DropDown
import FirebaseInstanceID
import Reachability
import Async
import PixelPhotoSDK

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceId:String? = ""
    var isInternetConnected = Connectivity.isConnectedToNetwork()
    var reachability :Reachability? = Reachability()
    let hostNames = ["google.com", "google.com", "google.com"]
    var hostIndex = 0


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        startHost(at: 0)
        initFrameworks(application: application, launchOptions: launchOptions)

        
        return true
    }

    func initFrameworks(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    {
        
                /*  Setup Key */
                GIDSignIn.sharedInstance().clientID = ControlSettings.googleClientKey

        
        /* Decryption of Cert Key */
        
        ServerCredentials.setServerDataWithKey(key: AppConstant.key)
        
        /* Init Swifty Beaver */
        let console = ConsoleDestination()
        let file = FileDestination()
        log.addDestination(console)
        log.addDestination(file)
        
        
        /* IQ Keyboard */
        
        IQKeyboardManager.shared.enable = true
        DropDown.startListeningToKeyboard()
//        GIDSignIn.sharedInstance().clientID = ControlSettings.googleClientKey
        
        //         OneSignal initialization
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,kOSSettingsKeyInAppLaunchURL: false]

        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ControlSettings.oneSignalAppId,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            log.verbose("User accepted notifications: \(accepted)")
        })
        let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
        log.verbose("Current playerId \(userId)")
         
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
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        let googleHandle =  GIDSignIn.sharedInstance().handle(url,
//                                                              sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?,
//                                                              annotation: options[UIApplication.OpenURLOptionsKey.annotation])
//
//        let facebookHandle =  SDKApplicationDelegate.shared.application(app, open: url, options: options)
//
//        return googleHandle || facebookHandle
//    }

}

//extension AppDelegate : OSSubscriptionObserver , OSPermissionObserver {
//    
//    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
//        
//        // Example of detecting answering the permission prompt
//        if stateChanges.from.status == OSNotificationPermission.notDetermined {
//            if stateChanges.to.status == OSNotificationPermission.authorized {
//                print("Thanks for accepting notifications!")
//            } else if stateChanges.to.status == OSNotificationPermission.denied {
//                print("Notifications not accepted. You can turn them on later under your iOS settings.")
//            }
//        }
//        // prints out all properties
//        print("PermissionStateChanges: \n\(stateChanges!)")
//    }
//    
//    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
//        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
//            print("Subscribed for OneSignal push notifications!")
//        }
//        print("SubscriptionStateChange: \n\(stateChanges!)")
//    }
//    
//}
extension AppDelegate{
    
    func startHost(at index: Int) {
        stopNotifier()
        setupReachability(hostNames[index], useClosures: false)
        startNotifier()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.startHost(at: (index + 1) % 3)
        }
    }
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = Reachability(hostname: hostName)
            
        } else {
            reachability = Reachability()
            
        }
        self.reachability = reachability ?? Reachability.init()
        
        
        if useClosures {
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    @objc func reachabilityChanged(_ note: Notification) {
        Async.main({
            let reachability = note.object as! Reachability
            switch reachability.connection {
            case .wifi:
                log.debug("Reachable via WiFi")
                self.isInternetConnected = true
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED)
            case .cellular:
                log.debug("Reachable via Cellular")
                self.isInternetConnected = true
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED)
                
            case .none:
                log.debug("Network not reachable")
                self.isInternetConnected = false
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED)
                
            }
        })
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
    }
}
