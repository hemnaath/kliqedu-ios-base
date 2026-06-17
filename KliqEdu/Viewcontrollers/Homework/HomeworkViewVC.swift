//
//  HomeworkViewVC.swift
//  KliqEdu
//
//  Created by codegama on 13/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SafariServices
import SDWebImage
import SkeletonView

class HomeworkViewVC: UIViewController {

    @IBOutlet weak var fileSizeLbl: UILabel!
    @IBOutlet weak var deleteEditView: UIStackView!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
//    @IBOutlet weak var createdByLbl: UILabel!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentNameLbl: UILabel!
    @IBOutlet weak var attachmentImg: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!

    var homeworkDetails = HomeWorkModel(dictionary: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.subjectLbl.layer.cornerRadius = 10
        self.subjectLbl.layer.masksToBounds = true

        self.gradeLbl.layer.cornerRadius = 10
        self.gradeLbl.layer.masksToBounds = true

        self.attachmentView.layer.cornerRadius = 12
        self.attachmentView.layer.borderWidth = 1
        self.attachmentView.layer.borderColor = UIColor.systemGray5.cgColor

        self.titleLbl.text = homeworkDetails?.title
        self.descriptionLbl.text = homeworkDetails?.descriptionValue
        self.subjectLbl.text = homeworkDetails?.subject
        self.dateLbl.text = "Created on \(homeworkDetails?.date ?? "")"
        self.gradeLbl.text = "Grade \(homeworkDetails?.grade ?? "") \(homeworkDetails?.section ?? "")"
      //  self.sectionLbl.text = homeworkDetails?.section ?? "All"
     //   self.createdByLbl.text = homeworkDetails?.created_by

        if let file = homeworkDetails?.file, !file.isEmpty {
            self.attachmentView.unhide()
            if let url = URL(string: file) {
                self.attachmentNameLbl.text = url.lastPathComponent
            } else {
                self.attachmentNameLbl.text = (file as NSString).lastPathComponent
            }
            self.attachmentImg.sd_setImage(with: URL(string: homeworkDetails?.file ?? ""), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
        } else {
            self.attachmentView.hide()
        }

        self.editBtn.isHidden = !(homeworkDetails?.is_editable ?? false)
        self.deleteBtn.isHidden = !(homeworkDetails?.is_deletable ?? false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if roleKey == "parent"{
            self.deleteEditView.hide()
        }else{
            self.deleteEditView.unhide()
            
            self.view.showAnimatedGradientSkeleton()
            getHomeworkInfoApi()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
  
    func getHomeworkInfoApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(homeworkDetails?.unique_id ?? "")",params: param, HTTPMethod: .get)
            
        self.callServiceMethod(service: "\(Constants.Urls.viewHomeworkUrl)/\(homeworkDetails?.unique_id ?? "")",method: .get, params: param, key: "viewHomeworkUrl", headers: headers)

    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func editBtnTapped(_ sender: Any) {
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AddHomeworkVC") as? AddHomeworkVC {
            vc.comingFrom = "edit"
            vc.homeworkDetails = homeworkDetails
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func deleteBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: Constants.appName, message: StringConstants.sureToDeleteTheHomework, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.yes, style: UIAlertAction.Style.destructive, handler: { action in
            LoadingIndicator.show()

            let param = [:] as [String : Any]
            
            let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.homeworkDetails?.unique_id ?? "")",params: param, HTTPMethod: .delete)
            
            self.callServiceMethod(service: "\(Constants.Urls.deleteHomeworkUrl)/\(self.homeworkDetails?.unique_id ?? "")",method: .delete, params: param, key: "deleteHomeworkUrl", headers: headers)
            
        }))
        alert.addAction(UIAlertAction(title: StringConstants.no, style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func attachmentBtnTapped(_ sender: Any) {
        print("Open Attachment")
        
        showDocumentOptions(homeworkDetails?.file ?? "")

    }

    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { response in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false

            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "deleteHomeworkUrl"{
                        LoadingIndicator.hide()

                        DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        }
                    }else if key == "viewHomeworkUrl"{
                        self.view.hideSkeleton()
                        if let dataList = responseDict.value(forKey: "data") as? NSDictionary {

                            self.homeworkDetails = HomeWorkModel(dictionary: dataList)

                            self.titleLbl.text = self.homeworkDetails?.title?.firstUppercased
                            self.descriptionLbl.text = self.homeworkDetails?.descriptionValue?.firstUppercased
                            self.dateLbl.text = " Added on \(self.homeworkDetails?.created_at ?? "")"
                            self.editBtn.isHidden = !(self.homeworkDetails?.is_editable ?? false)
                            self.deleteBtn.isHidden = !(self.homeworkDetails?.is_deletable ?? false)
                        }
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
            } else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                
               if ValidationClass.shouldForceLogoutForErrorCode(errorCode: errorCode) {
                    
                    self.performLogout(Vc: self)
                } else {
                    
                    self.showAnimatedToast(message: msg,type: .warning)

                }
            }
        }) { (error) in
            self.showAnimatedToast(message: StringConstants.pleaseTryAgain,type: .error)
            
            debugPrint(error)
        }
    }
    
    func showDocumentOptions(_ urlString: String) {

        let alert = UIAlertController(
            title: "Attachment",
            message: nil,
            preferredStyle: .actionSheet
        )

        let viewAction = UIAlertAction(title: "View", style: .default) { _ in
            self.openDocument(urlString)
        }
        viewAction.setValue(UIImage(systemName: "eye"), forKey: "image")

        let downloadAction = UIAlertAction(title: "Download", style: .default) { _ in
            self.downloadFile(urlString)
        }
        downloadAction.setValue(UIImage(systemName: "arrow.down.circle"), forKey: "image")

        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            guard let url = self.cleanURL(urlString) else { return }

            let activityVC = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )

            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }

            self.present(activityVC, animated: true)
        }
        shareAction.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")

        alert.addAction(viewAction)
        alert.addAction(downloadAction)
        alert.addAction(shareAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.view.tintColor = UIColor(hex: "#7367F0")

        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
    func openDocument(_ urlString: String) {
        //        let fixed = urlString.replacingOccurrences(of: "\\/", with: "/")
        //
        //        guard let url = URL(string: fixed) else { return }
        //
        //        let safariVC = SFSafariViewController(url: url)
        //        safariVC.preferredBarTintColor = .white
        //        safariVC.preferredControlTintColor = .systemBlue
        //
        //        self.present(safariVC, animated: true)
        
        let sb = UIStoryboard.init(name: Constants.StoryboardIds.mainSb, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ImageVC") as? ImageVC {
            vc.pic = urlString
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical   // animation
            
            present(vc, animated: true)
        }
    }
    func saveImage(_ fileURL: URL) {

        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return }
          showAnimatedToast(message: "Downloded")
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    func saveToFiles(_ fileURL: URL) {

        let activityVC = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(activityVC, animated: true)
    }
    func cleanURL(_ urlString: String) -> URL? {
        let fixed = urlString
            .replacingOccurrences(of: "\\/", with: "/")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return URL(string: fixed)
    }
    func downloadFile(_ urlString: String) {

        guard let url = cleanURL(urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.downloadTask(with: request) { tempURL, response, error in

            if let error = error {
                print("Download error:", error)
                return
            }

            guard let tempURL = tempURL else {
                print("No file received")
                return
            }

            let mimeType = response?.mimeType ?? ""

            DispatchQueue.main.async {
                if mimeType.contains("image") {
                    self.saveImage(tempURL)
                } else {
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        let fileManager = FileManager.default
                        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.lastPathComponent
                        let finalURL = docsURL.appendingPathComponent(fileName)
                        
                        try? fileManager.removeItem(at: finalURL)
                        try? fileManager.moveItem(at: tempURL, to: finalURL)
                        
                        // ✅ ONLY UI ON MAIN THREAD
                        DispatchQueue.main.async {
                            self.saveToFiles(finalURL)
                        }
                    }
                }
            }

        }.resume()
    }
}
