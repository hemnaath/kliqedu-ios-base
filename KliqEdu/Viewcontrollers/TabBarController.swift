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
}
