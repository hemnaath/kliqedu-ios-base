//
//  AppDelegate.swift
//  KliqEdu
//
//  Created by codegama on 24/03/26.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications
import IQKeyboardManagerSwift
import SwiftyJSON
import FirebaseCore

var DEVICE_TOKEN = "123456"
let gcmMessageIDKey = "gcm.message_id"

@main
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        api_Key = defaults.value(forKey: Constants.Keys.apiKey) as? String ?? ""
        salt_Key = defaults.value(forKey: Constants.Keys.saltKey) as? String ?? ""
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        roleKey = defaults.value(forKey: Constants.Keys.roleKey) as? String ?? ""
        
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        registerForPushNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

        application.registerForRemoteNotifications()
        Messaging.messaging().isAutoInitEnabled = true
        
        return true
    }

    /** Register for remote notifications to get an APNs token to use for registration to GCM */
    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
//            application.applicationIconBadgeNumber = NotifCount
        }
    }
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    // MARK: - Register for notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
       // DEVICE_TOKEN = token
    //    print("Device Token: \(token)")
        Messaging.messaging().apnsToken = deviceToken
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register:", error)
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "KliqEdu")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
         //   print("Message ID: \(messageID)")
        }
        // D. access the "badgeCount" from UserDefaults that you registered in step 1 above
         if var badgeCount = UserDefaults.standard.value(forKey: "badgeCount") as? Int {

             // E. increase the badgeCount by 1 since one notification came through
             badgeCount += 1

             // F. update UserDefaults with the updated badgeCount
             UserDefaults.standard.setValue(badgeCount, forKey: "badgeCount")

             // G. update the application with the current badgeCount so that it will appear on the app icon
          //   UIApplication.shared.applicationIconBadgeNumber = badgeCount
         }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }

    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
        
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
     //   print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        // Print full message.
        print("User_info: \(userInfo)")
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          //  print("Message ID: \(messageID)")
        }
//        if let dataValue = userInfo[AnyHashable("data")] as? String {
//            print("fcmBody1: \(dataValue)")
//
//            //defaults?.set(count, forKey: "count")
//            if let dictionaryMessage = GeneralSingleton.shared.convertToDictionary(text: dataValue) {
                
                let notificationType = userInfo["type"] as? String
                let contentUniqueId = userInfo["content_unique_id"] as? String ?? ""

                print("fcmBody1: \(notificationType ?? "")")
                
                if notificationType == "ANNOUNCEMENT"{
                   
                    let storyboard = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "AnnouncementDetailsVC") as! AnnouncementDetailsVC
                    vc.uniqueId = contentUniqueId

                    if let topVC = UIApplication.getTopViewController() {
                        topVC.navigationController?.navigationBar.isHidden = false
                        topVC.navigationController?.pushViewController(vc, animated: false)
                    }
                }else if notificationType == "LEAVE_UPDATE"{
                    
                    let storyboard = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LeaveViewVC") as! LeaveViewVC
                    vc.uniqeId = contentUniqueId

                    if let topVC = UIApplication.getTopViewController() {
                        topVC.navigationController?.navigationBar.isHidden = false
                        topVC.navigationController?.pushViewController(vc, animated: false)
                    }
                }else if notificationType == "FEES"{
                    
                    let storyboard = UIStoryboard(name: Constants.StoryboardIds.mainSb, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "FeesDetailsVC") as! FeesDetailsVC
                    vc.uniqueId = contentUniqueId

                    if let topVC = UIApplication.getTopViewController() {
                        topVC.navigationController?.navigationBar.isHidden = false
                        topVC.navigationController?.pushViewController(vc, animated: false)
                    }
                }
        completionHandler()
    }
}

public extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.windows.first?.rootViewController
        }
        return nil
    }()) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            return getTopViewController(base: tab.selectedViewController)
        }
        
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
}
extension AppDelegate  {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
                
        let dataDict:[String: Any] = ["token": fcmToken as Any]
        DEVICE_TOKEN = Messaging.messaging().fcmToken ?? ""
        print("FCM token: \(DEVICE_TOKEN)")
        
        let defaults = UserDefaults.standard
        defaults.set(fcmToken, forKey: Constants.Keys.deviceTokenKey)
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
             //   print("FCM registration token: \(token)")
                //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
            }
        }
    }
    //MARK: FCM functions
    private func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        debugPrint("--->messaging:\(messaging)")
        debugPrint("--->didRefreshRegistrationToken:\(fcmToken)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print("Received data message: \(remoteMessage.description)")
    }
}


