//
//  VisitorPassListVC.swift
//  KliqEdu
//

import UIKit
import SkeletonView
import CRRefresh
import Alamofire
import SwiftyJSON

class VisitorPassListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyTitleLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    /// Shown on the filter button while a status filter is applied.
    @IBOutlet weak var filterBadge: UIImageView!
    @IBOutlet weak var addPassBtn: UIButton!

    /// Applied filters from FilterVC: `["status": "Active" | "Expired" | "Cancelled"]`, empty for all passes.
    var filters: [String: Any] = [:]
    private var selectedState: VisitorPassModel.PassState? {
        switch (filters["status"] as? String)?.lowercased() {
        case "active": return .active
        case "expired": return .expired
        case "cancelled": return .cancelled
        default: return nil
        }
    }

    var passArray = [VisitorPassModel]()
    var page = 1
    var allItemsLoaded = false
    var isLoadingData = false
    private var hasLoadedOnce = false
    /// A pass was created / edited / cancelled while away: reload visibly instead of silently.
    private var passesChanged = false
    private var passChangeObserver: NSObjectProtocol?
    /// Responses from an older load (previous tab / earlier refresh) are ignored.
    private var requestGeneration = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        addPassBtn.dropShadow()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "VisitorPassTCell", bundle: nil), forCellReuseIdentifier: "VisitorPassTCell")
        tableView.isSkeletonable = true
        // Room below the last card so the add button doesn't cover it.
        tableView.contentInset.bottom = 90

        updateFilterUI()

        passChangeObserver = NotificationCenter.default.addObserver(forName: Notification.Name(Constants.Notifications.visitorPassChanged), object: nil, queue: .main) { [weak self] _ in
            self?.passesChanged = true
        }

        /// Pull to refresh
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.reloadPasses(showSkeleton: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        // Refresh on every visit so passes created, edited or cancelled elsewhere show up.
        // After a change show the skeleton, so the old list isn't mistaken for the updated one.
        reloadPasses(showSkeleton: !hasLoadedOnce || passesChanged)
        passesChanged = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }

    deinit {
        if let observer = passChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Actions

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func filterBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "FilterVC") as? FilterVC {
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical
            vc.comingFor = "VisitorPass"
            vc.appliedFilters = self.filters
            vc.onApplyFilter = { [weak self] filters in
                guard let self = self else { return }
                self.filters = filters
                self.updateFilterUI()
                self.passArray.removeAll()
                self.tableView.reloadData()
                self.reloadPasses(showSkeleton: true)
            }
            self.present(vc, animated: true)
        }
    }

    @IBAction func addPassTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CreateVisitorPassVC") as? CreateVisitorPassVC {
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func updateFilterUI() {
        filterBadge.isHidden = selectedState == nil
        emptyTitleLbl.text = selectedState.map { "No \($0.title) Passes" } ?? "No Visitor Passes"
    }

    // MARK: - API

    func reloadPasses(showSkeleton: Bool) {
        requestGeneration += 1
        page = 1
        allItemsLoaded = false
        isLoadingData = false
        if showSkeleton {
            emptyView.isHidden = true
            tableView.isHidden = false
            tableView.showAnimatedGradientSkeleton()
        }
        getPassesData()
    }

    func getPassesData() {
        guard !isLoadingData, !allItemsLoaded else { return }

        // AlamofireHC returns without calling back when offline, which would leave the skeleton running.
        guard NetworkManager.shared.isConnected else {
            showTopBanner(message: StringConstants.noInternetConnectionFound)
            finishLoading()
            return
        }
        isLoadingData = true
        let generation = requestGeneration
        let requestedPage = page

        // The list API's `status` filter currently fails (HTTP 500 for every value), so the
        // full list is requested and each tab filters it on the device.
        let param: [String: Any] = ["page": requestedPage, "limit": 10]
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/list", params: param, HTTPMethod: .post)

        AlamofireHC.request(Constants.Urls.parentVisitorPassListUrl, method: .post, params: param, headers: headers, shouldShowHUD: false, success: { response in
            guard generation == self.requestGeneration else { return }
            let result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if resultcheck {
                let data = result?["data"] as? NSDictionary
                let list = data?["passes"] as? [NSDictionary] ?? []
                var models = list.compactMap { VisitorPassModel(dictionary: $0) }
                // Filter by the pass's real state: an "Active" pass past its expiry counts as expired.
                if let state = self.selectedState {
                    models = models.filter { $0.state == state }
                }

                if requestedPage == 1 {
                    self.passArray = models
                } else {
                    self.passArray.append(contentsOf: models)
                }

                let pagination = data?["pagination"] as? NSDictionary
                let currentPage = pagination?["current_page"] as? Int ?? requestedPage
                let totalPages = pagination?["total_pages"] as? Int ?? 1
                if currentPage >= totalPages || list.isEmpty {
                    self.allItemsLoaded = true
                } else {
                    self.page = currentPage + 1
                }
                self.hasLoadedOnce = true
                // Filtering can leave a page short: keep loading until the screen is filled or the list ends.
                if self.passArray.count < 10 && !self.allItemsLoaded {
                    self.isLoadingData = false
                    self.getPassesData()
                    return
                }
                self.finishLoading()
            } else {
                if requestedPage == 1 { self.passArray.removeAll() }
                self.finishLoading()
                let errorCode: Int = result?["status_code"] as? Int ?? 0
                let msg = result?["message"] as? String ?? StringConstants.somethingWentWrong
                if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    self.performLogout(Vc: self)
                } else {
                    self.showAnimatedToast(message: msg, type: .warning)
                }
            }
        }) { error in
            guard generation == self.requestGeneration else { return }
            self.finishLoading()
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain, type: .error)
            debugPrint(error)
        }
    }

    private func finishLoading() {
        isLoadingData = false
        tableView.hideSkeleton()
        tableView.cr.endHeaderRefresh()
        tableView.isHidden = passArray.isEmpty
        emptyView.isHidden = !passArray.isEmpty
        tableView.reloadData()
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VisitorPassTCell", for: indexPath) as? VisitorPassTCell else {
            return UITableViewCell()
        }
        cell.configureCellWith(pass: passArray[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard passArray.indices.contains(indexPath.row) else { return }
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "VisitorPassDetailVC") as? VisitorPassDetailVC {
            vc.passDetails = passArray[indexPath.row]
            vc.uniqueId = passArray[indexPath.row].unique_id ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height * 2, !isLoadingData, !allItemsLoaded {
            getPassesData()
        }
    }
}

// MARK: - Skeleton
extension VisitorPassListVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "VisitorPassTCell"
    }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}
