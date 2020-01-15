//
//  ChatListVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import UIKit
import Async
import PixelPhotoSDK

class ChatListVC: BaseVC {
    
    @IBOutlet weak var addUserView: UIView!
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var chatListArray = [GetChatModel.Datum]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchUserChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false

    }
  
    func setupUI(){
        
        self.addUserView.isCircular()
        self.title = "Chats"
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        self.contentTblView.separatorStyle = .none
        self.contentTblView.register(R.nib.ppChatUserItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppChatUserItemTableViewCellID.identifier)
        
        let addUserTap = UITapGestureRecognizer(target: self, action: #selector(self.adduserTapped(_:)))
        self.addUserView.isUserInteractionEnabled = true
        self.addUserView.addGestureRecognizer(addUserTap)
        
    }
    @objc func adduserTapped(_ sender: UITapGestureRecognizer) {
        let vc = R.storyboard.chat.contactsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func refresh(sender:AnyObject) {
        self.chatListArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchUserChats()
        refreshControl.endRefreshing()
        
    }
    private func fetchUserChats(){
        if Connectivity.isConnectedToNetwork(){
            self.chatListArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                ChatManager.instance.getChatList(accessToken: accessToken, limit: 0, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.chatListArray = success?.data ?? []
                                if self.chatListArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.contentTblView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.contentTblView.reloadData()
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                                log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func deleteChat(userId:Int,position:Int){
        
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            ChatManager.instance.deleteChat(accessToken: accessToken, userId: userId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            self.chatListArray.remove(at: position)
                            self.contentTblView.reloadData()
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
extension ChatListVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = chatListArray[indexPath.row]
            self.deleteChat(userId: object.userID ?? 0, position: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.chatListArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ppChatUserItemTableViewCellID.identifier) as! PPChatUserItemTableViewCell
       
        
        let object = self.chatListArray[indexPath.row]
        cell.userNameLbl.text = object.username ?? ""
            cell.timeLbl.text = object.timeText ?? ""
            cell.messageLbl.text = object.lastMessage ?? ""
        
        let url = URL.init(string:object.avatar ?? "")
        cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let object = self.chatListArray[indexPath.row]
            let vc = R.storyboard.chat.chatVC()
            vc?.userID = object.userID ?? 0
            vc?.username = object.userData?.name ?? ""
            vc?.lastSeen = object.timeText ?? ""
            vc?.isAdmin = object.userData?.admin ?? 0
            self.navigationController?.pushViewController(vc!, animated: true)
        }

}
