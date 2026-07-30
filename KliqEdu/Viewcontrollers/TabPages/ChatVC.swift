//
//  ChatVC.swift
//  KliqEdu
//
//  Created by codegama on 12/07/26.
//

import UIKit
import SocketIO
import IQKeyboardManagerSwift
import SDWebImage
import Alamofire
import SwiftyJSON

class ChatVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var placeHolderlbl: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    let defaults = UserDefaults.standard
    let dateFormatter : DateFormatter = DateFormatter()
    let date = Date()
    var arrChatList = [SingleChatModel]()
    var studentsArray = StudentsModel(dictionary: [:])
    var teachersArray = TeachersModel(dictionary: [:])

    var selecteduniqueId = String()
    var send_by = 1
    var roomID = ""
    var chatListroomID = ""

    var receiverId = ""
    var comingFrom = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        userID = defaults.value(forKey: Constants.Keys.userIdKey) as? Int ?? 0
        self.placeHolderlbl.layer.cornerRadius = 25
        self.placeHolderlbl.layer.masksToBounds = true
        
        chatTextField.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.navigationController?.navigationBar.isHidden = true
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        socketConnect()
        print("tableView hidden:", tableView.isHidden)
        print("delegate:", tableView.delegate != nil)
        print("datasource:", tableView.dataSource != nil)
        let UseruniqueId = defaults.value(forKey: Constants.Keys.userUniqueIdKey) as? String ?? ""
        //self.roomID = "\(UseruniqueId)_TEA-0002"
        
        if roleKey == "teacher" {
            if comingFrom == "chatList"{
                self.roomID = chatListroomID
            }else{
                self.roomID = "\(selecteduniqueId)_\(UseruniqueId)"
            }
        }else if roleKey == "parent" {
            if comingFrom == "chatList"{
                self.roomID = chatListroomID
            }else{
                self.roomID = "\(UseruniqueId)_\(selecteduniqueId)"
            }
        }
        print("roomIDrj: \(roomID)")
        
        print("Loading messages for roomID:", roomID)
        arrChatList = CoreDataManager.shared.getMessages(room_id: roomID)
        print("Loaded messages count:", arrChatList.count)
        for msg in arrChatList {
            print("LOCAL -> roomId: \(msg.room_id ?? "") sender: \(msg.sender_id ?? "") receiver: \(msg.receiver_id ?? "") message: \(msg.message ?? "")")
        }
        print("Loaded local messages: \(arrChatList.count) for room: \(roomID)")
        tableView.reloadData()

        
        if roleKey == "teacher" {
            self.nameLbl.text = studentsArray?.full_name ?? ""
            self.subjectLbl.text = "Grade \(studentsArray?.studentClass ?? "")"
            let imageURL = (studentsArray?.student_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            print("namerjt: \(studentsArray?.full_name ?? "")")

            if !imageURL.isEmpty {
                self.placeHolderlbl.isHidden = true
                self.picture.isHidden = false
                self.picture.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
            } else {
                self.picture.image = nil
                self.picture.isHidden = true
                self.placeHolderlbl.isHidden = false
                let fullName = (studentsArray?.full_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let words = fullName.split(separator: " ")
                let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                self.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
            }
        } else {
            self.nameLbl.text = teachersArray?.full_name ?? ""
            self.subjectLbl.text = "\(teachersArray?.subject ?? "") Teacher"
            let imageURL = (teachersArray?.teacher_picture ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            print("namerjs: \(teachersArray?.full_name ?? "")")

            if !imageURL.isEmpty {
                self.placeHolderlbl.isHidden = true
                self.picture.isHidden = false
                self.picture.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "loader.png"), options: .refreshCached, completed: nil)
            } else {
                self.picture.image = nil
                self.picture.isHidden = true
                self.placeHolderlbl.isHidden = false
                let fullName = (teachersArray?.full_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let words = fullName.split(separator: " ")
                let firstInitial = words.first?.first.map { String($0).uppercased() } ?? ""
                let secondInitial = words.dropFirst().first?.first.map { String($0).uppercased() } ?? ""
                self.placeHolderlbl.text = secondInitial.isEmpty ? firstInitial : "\(firstInitial) \(secondInitial)"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        msgListApi()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableBackGesture()
    }
    func msgListApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.roomID)",params: param, HTTPMethod: .get)

        if roleKey == "teacher" {
            
            self.callServiceMethod(service: "\(Constants.Urls.teacherMsgUrl)/\(self.roomID)",method: .get, params: param, key: "msgListUrl", headers: headers)
        }else{
            self.callServiceMethod(service: "\(Constants.Urls.studentMsgUrl)/\(self.roomID)",method: .get, params: param, key: "msgListUrl", headers: headers)

        }
    }
    func msgDeleteApi(){
        
        let param = [:] as [String : Any]
        
        let (headers, _) = APIHelper.createHeadersAndSignature(endpoint: "/\(self.roomID)",params: param, HTTPMethod: .delete)

        if roleKey == "teacher" {
            
            self.callServiceMethod(service: "\(Constants.Urls.teacherMsgDeleteUrl)/\(self.roomID)",method: .delete, params: param, key: "msgDeleteApi", headers: headers)
            
        }else{
            self.callServiceMethod(service: "\(Constants.Urls.studentMsgDeleteUrl)/\(self.roomID)",method: .delete, params: param, key: "msgDeleteApi", headers: headers)

        }
    }
    @IBAction func callBtnTapped(_ sender: Any) {
        
    }
    @IBAction func sendBtnTapped(_ sender: Any) {
        self.sendMsgOnly()
        chatTextField.text = ""
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        disconnectSocket()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnectSocket()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let invocation = IQInvocation(self, #selector(didPressOnDoneButton))
    }
    
    @objc func didPressOnDoneButton() {
        chatTextField.resignFirstResponder()
        chatTextField.text = ""
    }

    func sendMsgOnly() {
        if chatTextField.text?.count != 0 {
            let timeStamp = Int64(Date().timeIntervalSince1970 * 1000)
            let timeStampString = String(timeStamp)
            
            var dict = Dictionary<String, Any>()
            dict["room_id"] = roomID
            let userUniqueId = defaults.value(forKey: Constants.Keys.userUniqueIdKey) as? String ?? ""
            dict["sender_id"] = userUniqueId
            dict["receiver_id"] = selecteduniqueId
            dict["message"] = chatTextField.text ?? ""
            dict["sent_by"] = 1
            dict["updated"] = "Just now"
            dict["message_id"] = timeStampString
            dict["timestamp"] = timeStamp

            socket?.emit("send_message", dict)
            
            var dict1 = Dictionary<String, Any>()
            dateFormatter.dateFormat = "HH:mm:ss"

            dict1["room_id"] = roomID
            dict1["sender_id"] = userUniqueId
            dict1["receiver_id"] = selecteduniqueId
            dict1["message"] = chatTextField.text ?? ""
            dict1["sent_by"] = 1
            dict1["updated"] = "Just now"
            dict1["message_id"] = timeStampString
            dict1["timestamp"] = timeStamp

            let modal1 = SingleChatModel.init(dictionary: dict1 as NSDictionary)
            print("Local model timestamp:", modal1?.timestamp ?? 0)
            arrChatList.insert(modal1!, at: 0)
            
            print("Saving LOCAL message -> roomId: \(roomID), sender: \(userUniqueId), receiver: \(selecteduniqueId), message: \(chatTextField.text ?? "")")
            CoreDataManager.shared.saveMessage(
                id: timeStampString,
                room_id: roomID,
                sender_id: userUniqueId,
                receiver_id: selecteduniqueId,
                senderName: "",
                message: chatTextField.text ?? "",
                timestamp: timeStamp
            )
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if chatTextField.isFirstResponder {
            chatTextField.text = nil
        } else {
            chatTextField.becomeFirstResponder()
            chatTextField.textColor = UIColor.themeColor
        }
        
        DispatchQueue.main.async {
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .bottom,
                animated: true
            )
        }
    }
    
    func socketConnect() {
        self.manager = SocketManager(
            socketURL: URL(string: "https://api.kliqedu.com")!,
            config: [
                .log(true),
                .compress,
                .forceWebsockets(true),
                .connectParams([
                    "token": token
                ])
            ]
        )
        
        self.socket = self.manager?.defaultSocket
        
        self.socket?.on(clientEvent: .connect) { data, ack in
            print("Socket Connected")

            let dict: [String: Any] = ["room_id": self.roomID]
            self.socket?.emit("join_room", dict)
            print("Joined room after connect: \(dict)")
        }

        self.socket?.on(clientEvent: .error) { data, ack in
            print("Socket Error:", data)
        }

//        self.socket?.on(clientEvent: .disconnect) { data, ack in
//            print("Socket Disconnected:", data)
//        }
        
        if self.socket?.status != .connected {
            self.socket?.connect()
        }

        // Removed redundant join_room logic; now joined after socket connects.

        socket!.on("receive_message") { (data, ack) in

            guard let dict = data.first as? [String: Any] else { return }

            print("receive_message:", dict)

            var localDict = dict

            let userUniqueId = self.defaults.string(forKey: Constants.Keys.userUniqueIdKey) ?? ""

            // Student app: backend sends PAR-xxxx as senderId.
            // Replace it with the logged-in student's uniqueId.
            if roleKey != "teacher" {
                let senderId = localDict["sender_id"] as? String ?? ""

                if senderId.hasPrefix("PAR-") {
                    localDict["sender_id"] = userUniqueId
                }
            }

            let senderId = localDict["sender_id"] as? String ?? ""
            let receiverId = localDict["receiver_id"] as? String ?? ""

            print("Logged User :", userUniqueId)
            print("Sender ID   :", senderId)
            print("Receiver ID :", receiverId)

            // Ignore the echoed message because it was already inserted in sendMsgOnly()
            if senderId == userUniqueId && receiverId != userUniqueId {
                print("Ignored duplicate message")
                return
            }

            let model = SingleChatModel(dictionary: localDict as NSDictionary)
            
            print("Saving SOCKET message -> roomId: \(localDict["room_id"] as? String ?? ""), sender: \(localDict["sender_id"] as? String ?? ""), receiver: \(localDict["receiver_id"] as? String ?? ""), message: \(localDict["message"] as? String ?? "")")
            CoreDataManager.shared.saveMessage(
                id: "\(localDict["id"] ?? UUID().uuidString)",
                room_id: localDict["room_id"] as? String ?? "",
                sender_id: localDict["sender_id"] as? String ?? "",
                receiver_id: localDict["receiver_id"] as? String ?? "",
                senderName: localDict["senderName"] as? String ?? "",
                message: localDict["message"] as? String ?? "",
                timestamp: Int64(localDict["timestamp"] as? Int ?? 0)
            )
            self.arrChatList.insert(model!, at: 0)

            DispatchQueue.main.async {
                self.tableView.reloadData()

                if self.arrChatList.count > 0 {
                    self.tableView.scrollToRow(
                        at: IndexPath(row: 0, section: 0),
                        at: .bottom,
                        animated: true
                    )
                }
            }
        }
    }

    func disconnectSocket() {
        self.manager = SocketManager(
            socketURL: URL(string: "https://api.kliqedu.com")!,
            config: [
                .log(true),
                .compress,
                .forceWebsockets(true),
                .connectParams([
                    "token": token
                ])
            ]
        )
        
        self.socket = self.manager?.defaultSocket
                self.socket?.on(clientEvent: .disconnect) { data, ack in
                    print("Socket Disconnected:", data)
                }
        socket?.on("disconnect") { (data, ack) in
            self.socket!.disconnect()

            var dict = Dictionary<String, Any>()
            self.socket!.emit("disconnect",dict)
            
            debugPrint("disconnect")
        }

        socket?.on(clientEvent: .disconnect) { data, ack in
            debugPrint("socket disconnected")
            print("kar_dict \(data)")
        }
    }
 
    private func formattedMessageTime(_ timestamp: Int64?) -> String {
        guard let timestamp = timestamp, timestamp > 0 else {
            return ""
        }

        let messageDate = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)

        // Show "Just now" if the message is within the last minute
        if Date().timeIntervalSince(messageDate) < 60 {
            return "Just now"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return formatter.string(from: messageDate)
    }
    
    //API calls
    func callServiceMethod(service: String,method: HTTPMethod, params: [String: Any], key: String,headers: [String: String]) {
        AlamofireHC.request(service, method: method, params: params, headers: headers, shouldShowHUD: false, success: { (response) in
            
            let  result = response.dictionaryObject
            let resultcheck = result?["success"] as? Bool ?? false
            
            if(resultcheck) {
                
                if let responseDict = result as NSDictionary? {
                    
                    if key == "msgListUrl"{
                        self.tableView.hideSkeleton()
                        
                        let listArray = result?["data"] as? Array<Dictionary<String,Any>> ?? []
                        
                        // Only clear the array if `skip` is 0, otherwise append
                        self.arrChatList.removeAll()
                        for item in listArray {
                            guard let model = SingleChatModel(dictionary: item as NSDictionary) else {
                                continue
                            }

                            let userUniqueId = self.defaults.string(forKey: Constants.Keys.userUniqueIdKey) ?? ""
                            let senderId = model.sender_id ?? ""
                            let receiverId = model.receiver_id ?? ""

                            // Ignore messages that already exist locally because they were inserted in sendMsgOnly().
                            if senderId == userUniqueId && receiverId != userUniqueId {
                                print("Ignored duplicate message from msgListApi")
                                continue
                            }else{
                                
                                if listArray.count > 0 {
                                    self.msgDeleteApi()
                                }
                            }

                            CoreDataManager.shared.saveMessage(
                                //  id: model.id ?? "",
                                room_id: model.room_id ?? "",
                                sender_id: model.sender_id ?? "",
                                receiver_id: model.receiver_id ?? "",
                                senderName: model.senderName ?? "",
                                message: model.message ?? "",
                                timestamp: model.timestamp ?? 0
                            )
                        }
                        
                        self.arrChatList = CoreDataManager.shared.getMessages(room_id: self.roomID)

                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                          
                            if self.arrChatList.count > 0 {
                                self.tableView.scrollToRow(
                                    at: IndexPath(row: 0, section: 0),
                                    at: .bottom,
                                    animated: false
                                )
                            } else {
                                
                            }
                        }
                    } else if key == "msgDeleteApi"{
                        print("msgDeleteApi called")
                    }
                } else {
                    self.showAnimatedToast(message: StringConstants.somethingWentWrong,type: .error)
                }
                
            }  else {
                
                let errorCode: Int = result!["status_code"] as? Int ?? 0
                let msg = result!["message"] as? String ?? ""
                if errorCode == 217{
                    self.tableView.isHidden = true
                   // self.emptyView.isHidden = false
                }
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


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("numberOfRows:", arrChatList.count)
        return arrChatList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //   print("cellForRowAt called:", indexPath.row)
    
        let localData = arrChatList[indexPath.row]

        let userUniqueId = defaults.value(forKey: Constants.Keys.userUniqueIdKey) as? String ?? ""
        print("Logged User :", userUniqueId)
        print("Sender      :", localData.sender_id ?? "")
        print("Receiver    :", localData.receiver_id ?? "")
        print("Message     :", localData.message ?? "")
        
        let isReceiver = (localData.receiver_id ?? "") == userUniqueId

        if isReceiver {
            // Left side (received message)
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRecieverTCell") as? ChatRecieverTCell {
                cell.msgLbl.text = localData.message ?? ""
                cell.updatedLbl.text = formattedMessageTime(localData.timestamp)
                cell.selectionStyle = .none
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                return cell
            }
        } else {
            // Right side (sent message)
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderTCell") as? ChatSenderTCell {
                cell.msgLbl.text = localData.message ?? ""
                cell.updatedLbl.text = formattedMessageTime(localData.timestamp)
                cell.selectionStyle = .none
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                return cell
            }
        }

        return UITableViewCell()
    }
}
