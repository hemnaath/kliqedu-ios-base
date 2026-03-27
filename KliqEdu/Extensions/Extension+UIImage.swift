//
//  Extension+UIImage.swift
//  Gambol
//
//  Created by Krishnendu Biswas on 22/05/20.
//  Copyright © 2019 Krishnendu Biswas. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    static func getImageWithUrlString(imageUrl: String, completion: @escaping (_ suucess: Bool, _ downloadedImageSize: UIImage?) -> Void){
        if let formattedImageUrl = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: formattedImageUrl, completionHandler: { (data, response, error) in
                guard error == nil else {
                    print("error in downloading image, error = \n\(error!)")
                    completion(false, nil)
                    return
                }
                if let downloadedImage = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        completion(true, downloadedImage)
                    }
                }
            }).resume()
        }
    }
    
    static func getImageUsingCacheWithUrlString(imageUrl: String, _ completion: @escaping (_ suucess: Bool, _ downloadedImage: UIImage?) -> Void){
        if let cachedImage = imageCache.object(forKey: imageUrl as AnyObject) as? UIImage {
            completion(true, cachedImage)
            return
        }
        if let formattedImageUrl = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: formattedImageUrl, completionHandler: { (data, response, error) in
                guard error == nil else {
                    print("error in downloading image, error = \n\(error!)")
                    completion(false, nil)
                    return
                }
                if let downloadedImage = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        imageCache.setObject(downloadedImage, forKey: imageUrl as AnyObject)
                        completion(true, downloadedImage)
                    }
                }
            }).resume()
        }
    }
    
    public func removeCache(forUrl: String) {
        imageCache.removeObject(forKey: forUrl as AnyObject)
    }
    
    /**
     this function is helpfull for resizing the image's resulation
     */
    
    public func resize(image targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
extension UIImage {
    func toString() -> String {
        guard let imageData = self.pngData() else {
            return ""
        }
        return imageData.base64EncodedString()
    }
}
