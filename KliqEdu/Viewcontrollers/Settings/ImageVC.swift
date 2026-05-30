//
//  ImageVC.swift
//  KliqEdu
//
//  Created by codegama on 24/05/26.
//

import UIKit
import SDWebImage

class ImageVC: UIViewController {

    @IBOutlet weak var picture: UIImageView!
    
    var pic = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.picture.sd_setImage(with: URL(string: pic), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}
