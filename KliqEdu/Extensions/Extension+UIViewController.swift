//
//  Extension+UIViewController.swift
//  Gambol
//
//  Created by Krishnendu Biswas on 22/05/20.
//  Copyright © 2019 Krishnendu Biswas. All rights reserved.
//

import UIKit
import MobileCoreServices

extension UIViewController{
    func showAnimatedToast(message: String, duration: Double = 2.0) {
        // Create the toast container view
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 15
        toastContainer.clipsToBounds = true
        
        // Create the toast message label
        let toastLabel = UILabel()
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        toastLabel.text = message
        toastLabel.numberOfLines = 0 // Allows multiple lines for longer messages
        
        // Add label to container
        toastContainer.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12)
        ])
        
        // Add container to view
        self.view.addSubview(toastContainer)
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Position container at the bottom of the view, with dynamic width based on content
        NSLayoutConstraint.activate([
            toastContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80),
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20)
        ])
        
        // Initial state for animation
        toastContainer.alpha = 0.0
        toastContainer.transform = CGAffineTransform(translationX: 0, y: 50)
        
        // Animate the toast to appear with fade-in and slide-up
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1.0
            toastContainer.transform = .identity
        }) { _ in
            // Fade-out and slide down after duration
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
                toastContainer.alpha = 0.0
                toastContainer.transform = CGAffineTransform(translationX: 0, y: 50)
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
    struct NavigationBarAppearance{
        
        var isTransparent: Bool!
        weak var barBackgroundColor: UIColor? = nil
        weak var barTintColor: UIColor? = nil
        
        init(isTransparent: Bool) {
            self.isTransparent = isTransparent
        }
        
        init(barBackgroundColor: UIColor) {
            self.barBackgroundColor = barBackgroundColor
            self.isTransparent = false
        }
        
        init(barTintColor: UIColor) {
            self.barTintColor = barTintColor
            self.isTransparent = false
        }
    }
    func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            
            switch self {
            
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
    public func customizeBackBarButtonItem(){
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    public func setStatusBarBackground(color: UIColor?) {
//        guard let statusBar = UIApplication.shared.statusBarUIView else { return }
//        statusBar.backgroundColor = color ?? .clear
    }
    
    
    //isForcefull = false for normal logout
    func performLogout(msg: String = "", Vc: UIViewController, isForcefull: Bool = true) {

        if isForcefull {

            let message = msg.isEmpty ? StringConstants.sessionExpired : msg

            let alert = UIAlertController(
                title: Constants.appName,
                message: message,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: StringConstants.ok, style: .destructive) { [weak self] _ in
                self?.logOutDeleteData()
            }

            alert.addAction(okAction)

            Vc.present(alert, animated: true)

        } else {

            self.logOutDeleteData()
        }
    }
    //clear the data on logout
    func logOutDeleteData() {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.Keys.isLoggedIn)
        defaults.removeObject(forKey: Constants.Keys.accessTokenKey)
        defaults.removeObject(forKey: Constants.Keys.userIdKey)
        defaults.removeObject(forKey: Constants.Keys.loginTypeKey)
        defaults.removeObject(forKey: Constants.Keys.userPicKey)
        defaults.removeObject(forKey: Constants.Keys.userNameKey)
        defaults.removeObject(forKey: Constants.Keys.emailIdKey)
        defaults.removeObject(forKey: Constants.Keys.socialUniqueId)
        defaults.removeObject(forKey: Constants.Keys.pushNotiStatus)
        defaults.removeObject(forKey: Constants.Keys.emailNotiStatus)
        defaults.removeObject(forKey: Constants.Keys.aboutTitle)
        defaults.removeObject(forKey: Constants.Keys.aboutDesc)
        defaults.removeObject(forKey: Constants.Keys.contactTitle)
        defaults.removeObject(forKey: Constants.Keys.contactDesc)
        defaults.removeObject(forKey: Constants.Keys.privacyTitle)
        defaults.removeObject(forKey: Constants.Keys.privacyDesc)
        defaults.removeObject(forKey: Constants.Keys.termsTitle)
        defaults.removeObject(forKey: Constants.Keys.termsDesc)
        defaults.removeObject(forKey: Constants.Keys.helpTitle)
        defaults.removeObject(forKey: Constants.Keys.helpDesc)
        defaults.removeObject(forKey: Constants.Keys.passcodeKey)
       // defaults.removeObject(forKey: Constants.Keys.faceID)
        defaults.removeObject(forKey: Constants.Keys.saltKey)
        defaults.removeObject(forKey: Constants.Keys.apiKey)
        defaults.removeObject(forKey: Constants.Keys.finalSignature)
        defaults.removeObject(forKey: Constants.Keys.private_key)
        defaults.removeObject(forKey: Constants.Keys.is2FAEnabled)

        defaults.set(true, forKey: "isLaunched")
        
        defaults.synchronize()
        navigateToRootVC()
//        let storyBoard = UIStoryboard(name: Constants.StoryboardIds.loginSB, bundle: nil)
//        if let vc = storyBoard.instantiateViewController(withIdentifier: "WelcomeFourVC") as? WelcomeFourVC {
//            defaults.set(true, forKey: "isLaunched")
//            defaults.synchronize()
//            self.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
//        }

    }
    
    //to Navigate to root VC
    
    func navigateToRootVC () {
        
        let story = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
        let vC = story.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        defaults.set(true, forKey: "isLaunched")
        defaults.synchronize()
        
        let navigationController = UINavigationController(rootViewController: vC)
        self.view.window?.rootViewController = navigationController
        self.view.window?.makeKeyAndVisible()
    }

 
    func setupNavigationBar(withTitle: String?, titleAppearance: (color: UIColor?, font: UIFont?)?, showLargeTitle: Bool, showBackBarButton: Bool, tintColor: UIColor?, barAppearance: NavigationBarAppearance?, barStyle: UIBarStyle, shadowColor: UIColor?, leftBarButtonItems: [UIBarButtonItem]?, rightBarButtonItems: [UIBarButtonItem]?) {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = withTitle
        navigationController?.navigationBar.prefersLargeTitles = showLargeTitle
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.setLeftBarButtonItems(leftBarButtonItems, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
        navigationItem.hidesBackButton = !showBackBarButton
        navigationController?.navigationBar.barStyle = barStyle
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.shadowImage = UIImage(color: .clear)
        
        if let barAppearance = barAppearance {
            
            if barAppearance.isTransparent {
                
                navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.clear, size: CGSize(width: 1, height: 1)), for: .default)
                navigationController?.navigationBar.isTranslucent = true
            }
            else if let barBackgroundColor = barAppearance.barBackgroundColor{
                navigationController?.navigationBar.setBackgroundImage(UIImage(color: barBackgroundColor, size: CGSize(width: 1, height: 1)), for: .default)
                navigationController?.navigationBar.isTranslucent = true
            }
            else if let barTintColor = barAppearance.barTintColor{
                navigationController?.navigationBar.barTintColor = barTintColor
            }
        }
        
        if let titleAppearance = titleAppearance {
            var titleAttributes = [NSAttributedString.Key: NSObject]()
            if let titleColor = titleAppearance.color{ titleAttributes[.foregroundColor] = titleColor}
            if let titleFont = titleAppearance.font{ titleAttributes[.font] = titleFont}
            if titleAttributes.count > 0 { navigationController?.navigationBar.titleTextAttributes = titleAttributes}
        }
    }
    
    //MARK:- For one action alert controller present
    
    public func showAlertWithOneAction(title:String, actionTtitle: String, style: UIAlertAction.Style, actionMethod: @escaping () -> Void , message:String){
        DispatchQueue.main.async(execute: {() -> Void in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTtitle, style: style, handler: { action in
                switch action.style{
                case .default:
                    actionMethod()
                case .cancel:
                    actionMethod()
                case .destructive:
                    actionMethod()
                }
            }))
            if let presentedVC = self.presentedViewController, presentedVC is UIAlertController {
                presentedVC.dismiss(animated: true, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
            else {
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func showAlertWithTwoAction(title:String, actionTtitle1: String, style1: UIAlertAction.Style, firstActionMethod: @escaping () -> Void, actionTtitle2: String, style2: UIAlertAction.Style, secondActionMethod: @escaping () -> Void , message:String){
        DispatchQueue.main.async(execute: {() -> Void in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTtitle1, style: style1, handler: { action in
                switch action.style{
                case .default:
                    firstActionMethod()
                case .cancel:
                    firstActionMethod()
                case .destructive:
                    firstActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle2, style: style2, handler: { action in
                switch action.style{
                case .default:
                    secondActionMethod()
                case .cancel:
                    secondActionMethod()
                case .destructive:
                    secondActionMethod()
                }
            }))
            
            if let presentedVC = self.presentedViewController, presentedVC is UIAlertController {
                presentedVC.dismiss(animated: true, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
            else {
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func showActionSheetWithThreeAction(title:String, actionTtitle1: String, style1: UIAlertAction.Style, firstActionMethod: @escaping () -> Void, actionTtitle2: String, style2: UIAlertAction.Style, secondActionMethod: @escaping () -> Void ,  actionTtitle3: String, style3: UIAlertAction.Style, thirdActionMethod: @escaping () -> Void ,  message:String){
        DispatchQueue.main.async(execute: {() -> Void in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: actionTtitle1, style: style1, handler: { action in
                switch action.style{
                case .default:
                    firstActionMethod()
                case .cancel:
                    firstActionMethod()
                case .destructive:
                    firstActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle2, style: style2, handler: { action in
                switch action.style{
                case .default:
                    secondActionMethod()
                case .cancel:
                    secondActionMethod()
                case .destructive:
                    secondActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle3, style: style3, handler: { action in
                switch action.style{
                case .default:
                    thirdActionMethod()
                case .cancel:
                    thirdActionMethod()
                case .destructive:
                    thirdActionMethod()
                }
            }))
            
            if let presentedVC = self.presentedViewController, presentedVC is UIAlertController {
                presentedVC.dismiss(animated: true, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
            else {
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
        
    func showActionSheetWithFiveAction(title:String, actionTtitle1: String, style1: UIAlertAction.Style, firstActionMethod: @escaping () -> Void, actionTtitle2: String, style2: UIAlertAction.Style, secondActionMethod: @escaping () -> Void ,  actionTtitle3: String, style3: UIAlertAction.Style, thirdActionMethod: @escaping () -> Void ,
                                       actionTtitle4: String, style4: UIAlertAction.Style, fourthActionMethod: @escaping () -> Void ,
                                       
                                       actionTtitle5: String, style5: UIAlertAction.Style, fifthActionMethod: @escaping () -> Void ,
                                       
                                       message:String){
        DispatchQueue.main.async(execute: {() -> Void in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: actionTtitle1, style: style1, handler: { action in
                switch action.style{
                case .default:
                    firstActionMethod()
                case .cancel:
                    firstActionMethod()
                case .destructive:
                    firstActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle2, style: style2, handler: { action in
                switch action.style{
                case .default:
                    secondActionMethod()
                case .cancel:
                    secondActionMethod()
                case .destructive:
                    secondActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle3, style: style3, handler: { action in
                switch action.style{
                case .default:
                    thirdActionMethod()
                case .cancel:
                    thirdActionMethod()
                case .destructive:
                    thirdActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle4, style: style4, handler: { action in
                switch action.style{
                case .default:
                    fourthActionMethod()
                case .cancel:
                    thirdActionMethod()
                case .destructive:
                    thirdActionMethod()
                }
            }))
            
            alert.addAction(UIAlertAction(title: actionTtitle5, style: style5, handler: { action in
                switch action.style{
                case .default:
                    fifthActionMethod()
                case .cancel:
                    thirdActionMethod()
                case .destructive:
                    thirdActionMethod()
                }
            }))
            
            if let presentedVC = self.presentedViewController, presentedVC is UIAlertController {
                presentedVC.dismiss(animated: true, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
            else {
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    /**
     This function checks whether the specified email string is a valid email address or not by formation.
     */
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0
            {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return returnValue
    }
    
    /**
     This function checks whether the specified password string is a valid email address or not by formation.
     */
    
    public func isValid(password: String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    /**
     showing error alert
     */
    
    public func ShowErrorAlert(with message: String){
        self.showAlertWithOneAction(title: Constants.appName, actionTtitle: "Dismiss", style: .destructive, actionMethod: {}, message: message)
    }
    public func ShowSuccessAlert(with message: String){
        self.showAlertWithOneAction(title: "Success", actionTtitle: "Okay", style: .destructive, actionMethod: {}, message: message)
    }
    public func ShowDarkModeAlert(with message: String){
        self.showAlertWithOneAction(title: "Dark/Light Mode", actionTtitle: "Okay", style: .destructive, actionMethod: {}, message: message)
    }
    
    func checkInstalledFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
    
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}

extension UIViewController: UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate{
//    
//    func showActionSheetForShowingPhotoPickerType(_ completion: @escaping(_ photpPicketType: PhotoPickerType?) -> Void){
//        let action = UIAlertController(title: "Choose photo from", message: nil, preferredStyle: .actionSheet)
//        action.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
//            completion(.camera)
//        }))
//        action.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action) in
//            completion(.library)
//        }))
//        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//            completion(nil)
//        }))
//        self.present(action, animated: true, completion: nil)
//    }
//    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showActionSheetForLogout( completion: @escaping( _ isAgreeForlogout: Bool) -> Void){
        let action = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .alert)
        action.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            completion(true)
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completion(false)
        }))
        self.present(action, animated: true, completion: nil)
    }
    
    func takePhotoFromCamera(imagePicker: UIImagePickerController) {
        if UIImagePickerController.availableCaptureModes(for: .front) != nil {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.cameraDevice = .front
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker,animated: true,completion: nil)
        }else if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.cameraDevice = .rear
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker,animated: true,completion: nil)
        }  else {
            self.noCamera()
        }
    }
    func takePhotoFromGallery(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker,animated: true, completion: nil)
        }
    }
    func noCamera() {
        self.showAlertWithOneAction(title: "Error", actionTtitle: "OK", style: .default, actionMethod: {}, message: "Sorry, this device has no camera")
    }
}
// MARK: - Methods
extension UIAlertController {
    
    /// Present alert view controller in the current view controller.
    ///
    /// - Parameters:
    ///   - animated: set true to animate presentation of alert controller (default is true).
    ///   - vibrate: set true to vibrate the device while presenting the alert (default is false).
    ///   - completion: an optional completion handler to be called after presenting alert controller (default is nil).
    
    public func show(animated: Bool = true, vibrate: Bool = false, style: UIBlurEffect.Style? = nil, completion: (() -> Void)? = nil) {
        
        /// TODO: change UIBlurEffectStyle
        //        if let style = style {
        //            for subview in view.allSubViewsOf(type: UIVisualEffectView.self) {
        //                subview.effect = UIBlurEffect(style: style)
        //            }
        //        }
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
            //            if vibrate {
            //                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            //            }
        }
    }
    
    /// Add an action to Alert
    ///
    /// - Parameters:
    ///   - title: action title
    ///   - style: action style (default is UIAlertActionStyle.default)
    ///   - isEnabled: isEnabled status for action (default is true)
    ///   - handler: optional action handler to be called when button is tapped (default is nil)
    func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        //let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        //let action = UIAlertAction(title: title, style: isPad && style == .cancel ? .default : style, handler: handler)
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled
        
        // button image
        if let image = image {
            action.setValue(image, forKey: "image")
        }
        
        // button title color
        if let color = color {
            action.setValue(color, forKey: "titleTextColor")
        }
        
        addAction(action)
    }
    
    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }
    
    func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: "attributedTitle")
    }
    
    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }
    
    func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: "attributedMessage")
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - height: height of content viewController
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
}

private var enableBackGestureKey: UInt8 = 0

extension UIViewController: UIGestureRecognizerDelegate{

    // MARK: - Toggle Flag
    var isBackGestureEnabled: Bool {
        get { objc_getAssociatedObject(self, &enableBackGestureKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &enableBackGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Call this from VC to enable gesture
    func enableBackGesture() {
        isBackGestureEnabled = true
        setupBackGestureIfNeeded()
    }
     func disableBackGesture() {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    // MARK: - Enable gesture only when flag = true
    private func setupBackGestureIfNeeded() {
        guard isBackGestureEnabled else { return }

        if let navController = self.navigationController {
            navController.interactivePopGestureRecognizer?.isEnabled = true
            navController.interactivePopGestureRecognizer?.delegate = self
        }

        let hasCustomGestures = view.gestureRecognizers?.contains(where: { $0 is UIScreenEdgePanGestureRecognizer }) ?? false
        if !hasCustomGestures {
            let leftEdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackSwipe(_:)))
            leftEdgeSwipe.edges = .left
            view.addGestureRecognizer(leftEdgeSwipe)
        }
    }

    @objc private func handleBackSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard isBackGestureEnabled else { return }

        if gesture.state == .recognized {
            navigationController?.popViewController(animated: true)
        }
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return isBackGestureEnabled   // 🔥 Allow only when enabled
    }
    // Status bar bg color
    func setStatusBarBackgroundColor(_ color: UIColor) {
           guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                 let window = windowScene.windows.first else { return }

           let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

           let statusBarView = UIView(frame: CGRect(
               x: 0,
               y: 0,
               width: window.frame.width,
               height: statusBarHeight
           ))

           statusBarView.backgroundColor = color
           statusBarView.tag = 999   // for removal
           window.addSubview(statusBarView)
       }

       func removeStatusBarBackground() {
           guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                 let window = windowScene.windows.first else { return }

           window.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
       }
}

