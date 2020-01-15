//
//  ChatVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 29/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import DropDown
import SwiftEventBus
import PixelPhotoSDK

class ChatVC: BaseVC {
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTxtViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentTblView: UITableView!
    
    var userID:Int? = 0
    var username:String? = ""
    var lastSeen:String? = ""
    var isAdmin:Int? = 0
    private let moreDropdown = DropDown()
    private var messagesArray = [GetUserChatModel.Message]()
    private var scrollStatus:Bool? = true
    private var messageCount:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.customizeDropdown()
        self.fetchChatList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            self.fetchChatList()
            
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false

    }
    deinit {
        SwiftEventBus.unregister(self)
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendPressed(_ sender: Any) {
        if self.messageTxtView.text == "Your Message here..."{
            log.verbose("will not send message as it is PlaceHolder...")
        }else{
            self.sendMessage()
        }
    }
    @IBAction func morePressed(_ sender: Any) {
        self.moreDropdown.show()
    }
    func setupUI(){
        log.verbose("userId = \(self.userID ?? 0)")
        self.usernameLabel.text = self.username ?? ""
        self.timeLabel.text = "last seen \(self.lastSeen ?? "")"
        
        self.contentTblView.separatorStyle = .none
        self.contentTblView.register(R.nib.ppSenderChatItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppSenderChatItemTableViewCellID.identifier)
        
        self.contentTblView.register(R.nib.ppReceiverChatItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppReceiverChatItemTableViewCellID.identifier)
        self.textViewPlaceHolder()
        
        
    }
    private func sendMessage(){
        let messageHashId = Int(arc4random_uniform(UInt32(100000)))
        let messageText = messageTxtView.text ?? ""
        let recipientId = self.userID ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            ChatManager.instance.sendMessage(accessToken: accessToken, userId: recipientId, hashId: messageHashId, text: messageText, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            if self.messagesArray.count == 0{
                                log.verbose("Will not scroll more")
                                self.textViewPlaceHolder()
                                self.view.resignFirstResponder()
                            }else{
                                self.textViewPlaceHolder()
                                self.view.resignFirstResponder()
                                log.debug("userList = \(success?.code ?? "")")
                                let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                self.contentTblView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                            }
                            
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                            
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
        })
    }
    private func clearChat(){
        
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let userID = self.userID ?? 0
        Async.background({
            ChatManager.instance.clearChat(accessToken: accessToken, userId: userID, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
        })
    }
    private func blockUser(){
        if self.isAdmin == 1{
            let alert = UIAlertController(title: "", message: "You cannot block this user because it is administrator", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion:nil)
        }else{
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.userID ?? 0
            Async.background({
                BlockUsersManager.instance.blockUnBlockUsers(accessToken: accessToken, userId: userId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.message ?? "")")
                                self.view.makeToast("User has been blocked!!")
                                self.navigationController?.popViewController(animated: true)
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.errors?.errorText)
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription)
                                log.error("error = \(error?.localizedDescription)")
                            }
                        })
                    }
                })
                
            })
        }
    }
    private func fetchChatList(){
        let userId = self.userID ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ChatManager.instance.getUserChats(accessToken: accessToken, userId: userId, limit: 0, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.code ?? "")")
                            self.messagesArray = success?.data.messages ?? []
                            
                            self.contentTblView.reloadData()
                            if self.scrollStatus!{
                                if self.messagesArray.count == 0{
                                    log.verbose("Will not scroll more")
                                }else{
                                    self.scrollStatus = false
                                    self.messageCount = self.messagesArray.count ?? 0
                                    let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                    self.contentTblView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                }
                            }else{
                                if self.messagesArray.count > self.messageCount!{
                                    
                                    self.messageCount = self.messagesArray.count ?? 0
                                    let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                    self.contentTblView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                }else{
                                    log.verbose("Will not scroll more")
                                }
                                log.verbose("Will not scroll more")
                                
                            }
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
        })
    }
    private func adjustHeight(){
        let size = self.messageTxtView.sizeThatFits(CGSize(width: self.messageTxtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        messageTxtViewHeightConstraints.constant = size.height
        self.viewDidLayoutSubviews()
        self.messageTxtView.setContentOffset(CGPoint.zero, animated: false)
    }
    private func textViewPlaceHolder(){
        messageTxtView.delegate = self
        messageTxtView.text = "Your Message here..."
        messageTxtView.textColor = UIColor.lightGray
    }
    
    private func customizeDropdown(){
        moreDropdown.dataSource = ["Block" , "Clear Chat"]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        //        moreDropdown.bottomOffset = CGPoint(x: 312, y:-270)
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.blockUser()
            }else if index == 1{
                self.clearChat()

            }
            print("Index = \(index)")
        }
    }
}

extension ChatVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            self.messageTxtView.text = ""
            textView.textColor = UIColor.black
            
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your message here..."
            textView.textColor = UIColor.lightGray
            
            
        }
    }
}

extension ChatVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.messagesArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let object = self.messagesArray[indexPath.row]
        
        if object.position == "right" {
            let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.ppSenderChatItemTableViewCellID.identifier ) as! PPSenderChatItemTableViewCell
            
            cell.messageTxtView.text = object.text ?? ""
            cell.timeLbl.text =  object.timeText ?? ""
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ppReceiverChatItemTableViewCellID.identifier) as! PPReceiverChatItemTableViewCell
        
        cell.messageTxtView.text = object.text ?? ""
        cell.timeLbl.text =  object.timeText ?? ""
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
