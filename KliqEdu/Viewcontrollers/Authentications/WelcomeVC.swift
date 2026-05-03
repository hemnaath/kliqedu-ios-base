//
//  WelcomeVC.swift
//  herald-exchange
//
//  Created by Karthick RJ on 24/04/25.
//

import UIKit

class WelcomeVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var slider1: UIView!
    @IBOutlet weak var slider2: UIView!
    @IBOutlet weak var slider3: UIView!
    
    @IBOutlet weak var swipeOuterView: UIView!
    @IBOutlet weak var nextBtnView: UIView!
    @IBOutlet weak var swipeBtn: TGFlingActionButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var titleArray = ["Communication Made Easy","Smart Fee & Finance Management","Classroom & Learning Simplified"]

    var descArray = ["Connect with teachers and parents instantly.Get real-time updates and messages., and notifications in one place.","Manage fees and payments.Track transactions in one place.","Manage classes and student activities.Track progress and performance easily."]
    
    var imageArray = ["11","22","33"]
    lazy var sliders: [UIView] = [slider1, slider2, slider3]
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSliders()

        defaults.set(false, forKey: "isLaunched")
        defaults.synchronize()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        // Disable paging
      //  setupCollectionView()
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = collectionView.bounds.size
        collectionView.collectionViewLayout = layout
        collectionView.clipsToBounds = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = collectionView.frame.size
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
        }
        swipeBtn.addTarget(self,action: #selector(swipeBtnTapped(_:)),for: .valueChanged)
    }
    override func viewWillAppear(_ animated: Bool) {
        nextBtnView.isHidden = false
        swipeOuterView.isHidden = true
        swipeBtn.isHidden = true
    }
    func setupSliders() {
        sliders.forEach {
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 2
        }
        updateSlider(index: 0)
    }
    func updateSlider(index: Int) {

        for (i, slider) in sliders.enumerated() {

            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut],
                animations: {
                    slider.backgroundColor = (i == index) ? .theme : .lightGray
                    slider.transform = (i == index)
                    ? CGAffineTransform(scaleX: 1.1, y: 1)
                    : .identity })
        }
    }

    func moveCollectionToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionView.contentOffset.y ,width : self.collectionView.frame.width,height : self.collectionView.frame.height)
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true // Disable horizontal scrolling
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
    @IBAction func nextButtonTapped(_ sender: UIButton) {
       
        if currentIndex == titleArray.count - 1{
            print("Last index1:", currentIndex)
            let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                defaults.synchronize()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let desiredScrollPosition = (currentIndex < titleArray.count - 1) ? currentIndex + 1 : 0
            collectionView.scrollToItem(at: IndexPath(item: desiredScrollPosition, section: 0), at: .centeredHorizontally, animated: true)
            print("Last index:", currentIndex)
            //  self.submitMcq()
            
        }
        print("tapped")
    }
    @IBAction func swipeBtnTapped(_ sender: TGFlingActionButton) {
        print(sender.swipe_direction)
        print("🚀 IBAction called")
        if sender.swipe_direction == .right {
            
            guard let nav = self.navigationController else {
                print("❌ No navigation controller")
                return
            }
            
            let sb = UIStoryboard(name: Constants.StoryboardIds.loginSB, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "LoginVC")
            
            nav.pushViewController(vc, animated: true)
        }
    }
    @IBAction func skipBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.loginSB, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / collectionView.frame.size.width)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    func updateCurrentIndex() {
        currentIndex = Int(collectionView.contentOffset.x / collectionView.frame.width)
        updateSlider(index: currentIndex)
        updateBottomButtons()
    }
    func updateBottomButtons() {

        let page = Int(collectionView.contentOffset.x / collectionView.frame.width)
        currentIndex = page

        if page == titleArray.count - 1 {
            nextBtnView.isHidden = true
            swipeOuterView.isHidden = false
            swipeBtn.isHidden = false
        } else {
            nextBtnView.isHidden = false
            swipeOuterView.isHidden = true
            swipeBtn.isHidden = true
        }
    }
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of dates you want to display (e.g., 7 for a week)
        return titleArray.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if the displayed cell is the last cell in the collection view
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            // You have reached the last index
            print("Reached the last index")
            // You can now load more data, paginate, or perform any other action
        }else{
        
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeCCell", for: indexPath) as! WelcomeCCell
        let titleData = titleArray[indexPath.row]
        let descData = descArray[indexPath.row]

        cell.titleLbl.text = titleData
        cell.descriptionLbl.text = descData
        cell.descriptionLbl.addInterlineSpacing(spacingValue: 5, alignment: .center)
        cell.picture.image = UIImage(named: imageArray[indexPath.row])

        return cell
    }
}
