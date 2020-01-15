//
//  BlockUserVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class BlockUserVC: BaseVC {
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var blockedUsersArray = [BlockUserModel.Datum]()
    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchBlockUsers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI(){
        
        self.title = "Block Users"
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        
        self.contentTblView.separatorStyle = .none
        self.contentTblView.register(R.nib.ppBlockedUserItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppBlockedUserItemTableViewCellID.identifier)
        
    
    }
    @objc func refresh(sender:AnyObject) {
        self.blockedUsersArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchBlockUsers()
        refreshControl.endRefreshing()
    }
    
    private func fetchBlockUsers(){
        if Connectivity.isConnectedToNetwork(){
            self.blockedUsersArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                BlockUsersManager.instance.getBlockUsers(accessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.blockedUsersArray = success?.data ?? []
                                if self.blockedUsersArray.isEmpty{
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
    private func unBlockUser(userId:Int,index:Int){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                BlockUsersManager.instance.blockUnBlockUsers(accessToken: accessToken, userId: userId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.blockedUsersArray.remove(at: index)
                                self.contentTblView.reloadData()
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
    
}

extension BlockUserVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .default, title: "Unblock", handler: {
            (action, indexPath) in
            let object = self.blockedUsersArray[indexPath.row]
            self.unBlockUser(userId: object.userID ?? 0, index: indexPath.row)
        })
        action1.backgroundColor = UIColor.lightGray
        return [action1]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.blockedUsersArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ppBlockedUserItemTableViewCellID.identifier) as! PPBlockedUserItemTableViewCell
        let object = blockedUsersArray[indexPath.row]
        cell.profileNameLbl.text = object.username ?? ""
        let url = URL.init(string:object.avatar ?? "")
        cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
