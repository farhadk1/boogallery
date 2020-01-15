//
//  NotificationSettingsVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class NotificationSettingsVC: BaseVC {
    
    @IBOutlet weak var likeSwitch: UISwitch!
    @IBOutlet weak var commentSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    @IBOutlet weak var mentionSwitch: UISwitch!
    @IBOutlet weak var receiveNotificationLbl: UILabel!
    @IBOutlet weak var likedMyPostLbl: UILabel!
    @IBOutlet weak var commentedOnmyPostLbl: UILabel!
    @IBOutlet weak var followedMeLbl: UILabel!
    @IBOutlet weak var mentionedLbl: UILabel!
    
    private var onLike : String? = ""
    private var onComment : String? = ""
    private var onFollow : String? = ""
    private var onMention : String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func mentionMePressed(_ sender: UISwitch) {
        if sender.isOn {
            self.onMention = "\(1)"
        }else{
            self.onMention = "\(0)"

        }
    }
    
    @IBAction func postSwitchpressed(_ sender: UISwitch) {
        if sender.isOn {
            self.onLike = "\(1)"
        }else{
            self.onLike = "\(0)"
            
        }
    }
    
    @IBAction func commentPostSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            self.onComment = "\(1)"
        }else{
            self.onComment = "\(0)"
            
        }
    }
    
    @IBAction func followMePressed(_ sender: UISwitch) {
        if sender.isOn {
            self.onFollow = "\(1)"
        }else{
            self.onFollow = "\(0)"
            
        }
    }
    
    func setupUI(){
        
        self.receiveNotificationLbl.text = NSLocalizedString("Receive Notification when some one", comment: "")
        self.likedMyPostLbl.text = NSLocalizedString("Liked my post", comment: "")
        self.commentedOnmyPostLbl.text = NSLocalizedString("Commented on my post", comment: "")
        self.followedMeLbl.text = NSLocalizedString("Followed me", comment: "")
        self.mentionedLbl.text = NSLocalizedString("Mentioned me", comment: "")
        
        
        if AppInstance.instance.userProfile?.data?.nOnLike == "1" {
            self.likeSwitch.isOn = true
            self.onLike = "\(1)"
        }else{
            self.likeSwitch.isOn = false
            self.onLike = "\(0)"

        }
        
        if AppInstance.instance.userProfile?.data?.nOnComment == "1" {
            self.commentSwitch.isOn = true
            self.onComment = "\(1)"
        }else{
            self.commentSwitch.isOn = false
            self.onComment = "\(0)"

        }
        
        if AppInstance.instance.userProfile?.data?.nOnFollow == "1"{
            self.followSwitch.isOn = true
            self.onFollow = "\(1)"

        }else{
            self.followSwitch.isOn = false
            self.onFollow = "\(0)"

        }
        
        if AppInstance.instance.userProfile?.data?.nOnMention == "1"{
            self.mentionSwitch.isOn = true
            self.onMention = "\(1)"

        }else{
            self.mentionSwitch.isOn = false
            self.onMention = "\(0)"

        }
        
        self.title = "Notification Setting"
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    
    @objc func Save(){
        self.updateNotificationSetting()
    }
    private func updateNotificationSetting(){
        self.showProgressDialog(text: "Loading...")
        let onLike = self.onLike ?? ""
        let onComment = self.onComment ?? ""
        let onfollow = self.onFollow ?? ""
        let onMention = self.onMention ?? ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProfileManger.instance.updateNotificationSettings(accessToken: accessToken, onLike: onLike, onComment: onComment, Follow: onfollow, mention: onMention, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            AppInstance.instance.fetchUserProfile()
                            self.view.makeToast(success?.message ?? "")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog { self.view.makeToast(sessionError?.errors?.errorText ?? "")
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
    }
}
