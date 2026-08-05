//
//  ChatVC.swift
//  KliqEdu
//
//  Created by codegama on 12/07/26.
//

import UIKit
import IQKeyboardManagerSwift

class ChatVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var placeHolderlbl: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    
    let dateFormatter : DateFormatter = DateFormatter()
    let date = Date()
    struct DummyMessage {
        let text: String
        let isSender: Bool
    }

    var arrChatList: [DummyMessage] = [
        DummyMessage(text: "Hi Mam", isSender: false),
        DummyMessage(text: "Hello Ramesh", isSender: true),
        DummyMessage(text: "Did you complete today's homework?", isSender: false),
        DummyMessage(text: "Yes Mam, I finished it.", isSender: true),
        DummyMessage(text: "Very good.", isSender: false),
        DummyMessage(text: "Can you check it once?", isSender: true),
        DummyMessage(text: "Sure, send me the notebook tomorrow.", isSender: false),
        DummyMessage(text: "Okay Mam.", isSender: true),
        DummyMessage(text: "Also revise Chapter 5.", isSender: false),
        DummyMessage(text: "I'll do that today.", isSender: true),
        DummyMessage(text: "Excellent.", isSender: false),
        DummyMessage(text: "Thank you!", isSender: true),
        DummyMessage(text: "See you tomorrow.", isSender: false),
        DummyMessage(text: "See you Mam. Bye!", isSender: true),
        DummyMessage(text: "Take care.", isSender: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeHolderlbl.layer.cornerRadius = 25
        self.placeHolderlbl.layer.masksToBounds = true
        chatTextField.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.navigationController?.navigationBar.isHidden = true
        tableView.reloadData()
        nameLbl.text = "Mrs. Priya"
        subjectLbl.text = "Mathematics Teacher"
        picture.isHidden = true
        placeHolderlbl.isHidden = false
        placeHolderlbl.text = "MP"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        tableView.reloadData()
    }
    @IBAction func callBtnTapped(_ sender: Any) {
        
        let mobile = "9876543210"

        let alert = UIAlertController(title: "Call", message: mobile, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
            if let url = URL(string: "tel://\(mobile)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))

        self.present(alert, animated: true)

    }
    @IBAction func sendBtnTapped(_ sender: Any) {
        guard let text = chatTextField.text, !text.isEmpty else { return }
        arrChatList.append(DummyMessage(text: text, isSender: true))
        chatTextField.text = ""
        tableView.reloadData()
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let invocation = IQInvocation(self, #selector(didPressOnDoneButton))
    }
    
    @objc func didPressOnDoneButton() {
        chatTextField.resignFirstResponder()
        chatTextField.text = ""
    }

    func sendMsgOnly() {}


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrChatList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = arrChatList[indexPath.row]
        if message.isSender {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderTCell") as! ChatSenderTCell
            cell.msgLbl.text = message.text
            cell.updatedLbl.text = "09:30 AM"
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRecieverTCell") as! ChatRecieverTCell
            cell.msgLbl.text = message.text
            cell.updatedLbl.text = "09:30 AM"
            cell.selectionStyle = .none
            return cell
        }
    }
}
