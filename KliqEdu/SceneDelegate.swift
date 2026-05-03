//
//  SceneDelegate.swift
//  KliqEdu
//
//  Created by codegama on 24/03/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleDeepLink(url: url)
            }
        }
    }
    func scene(_ scene: UIScene,
               continue userActivity: NSUserActivity) {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return }

        handleDeepLink(url: url)
    }
    func handleDeepLink(url: URL) {

        guard url.absoluteString.contains("reset-password") else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let token = components?.queryItems?.first(where: {$0.name == "token"})?.value ?? ""
    //    let email = components?.queryItems?.first(where: {$0.name == "email"})?.value ?? ""
        
        let sb = UIStoryboard(name: Constants.StoryboardIds.loginSB, bundle: nil)

        if let vc = sb.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
            vc.token = token
            //     vc.email = email
            
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

