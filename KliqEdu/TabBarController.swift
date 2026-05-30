//
//  TabBarController.swift
//  TodoApp
//
//  Created by Karthick RJ on 06/11/23.
//

import UIKit


class TabBarController: UITabBarController,UITabBarControllerDelegate{
    
    private let sendButton = UIButton()
    private let sendButtonBackground = UIView()
    private var currentTourIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.view.layoutIfNeeded()
        self.tabBar.layoutIfNeeded()
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        token = defaults.value(forKey: Constants.Keys.accessTokenKey) as? String ?? ""
        self.navigationController?.isNavigationBarHidden = true
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .clear
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
      
        // Create a top border view
          let topLine = UIView(frame: CGRect(x: 0, y: -15, width: tabBar.frame.width, height: 1))
    
          // Add it to the tabBar
          tabBar.addSubview(topLine)
        
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let index = viewControllers?.firstIndex(of: viewController) else {
            return true
        }

        switch index {

        case 1:
            // Homework
            let homeworkPermission = defaults.value(forKey: Constants.Keys.homeworkPermissionKey) as? Bool ?? false

            if !homeworkPermission {
                self.showAnimatedToast(message: "You don't have permission to access this page", type: .warning)
                return false
            }

        case 2:
            // Leave
            let leavePermission = defaults.value(forKey: Constants.Keys.leavePermissionKey) as? Bool ?? false

            if !leavePermission {
                self.showAnimatedToast(message: "You don't have permission to access this page", type: .warning)
                return false
            }

        case 3:
            // Settings
            let settingsPermission = defaults.value(forKey: Constants.Keys.settingsPermissionKey) as? Bool ?? false

            if !settingsPermission {
                self.showAnimatedToast(message: "You don't have permission to access this page", type: .warning)
                return false
            }

        default:
            break
        }

        return true
    }
}
