//
//  WebviewVC.swift
//  EFIBank
//
//  Created by Karthick RJ on 11/12/24.
//

import UIKit
import WebKit

class WebviewVC: UIViewController,WKNavigationDelegate {
  
    var docFile = ""
    var titel = "KYC Verification"
    @IBOutlet weak var titelLbl: UILabel!
    @IBOutlet weak var documentView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        titelLbl.text = titel

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        documentView.navigationDelegate = self

        if docFile != "" {
            LoadingIndicator.show()

            let url: URL = URL(string: docFile) ?? URL(fileURLWithPath: "")
            documentView.load(URLRequest(url: url))
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingIndicator.hide()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LoadingIndicator.hide()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        LoadingIndicator.hide()
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
