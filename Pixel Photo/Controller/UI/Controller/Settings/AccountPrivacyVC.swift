//
//  AccountPrivacyVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import ActionSheetPicker_3_0
import PixelPhotoSDK

class AccountPrivacyVC: BaseVC {
    
    @IBOutlet weak var audienceBtn: UIButton!
    @IBOutlet weak var directMessageBtn: UIButton!
    @IBOutlet weak var searchEngineSwitch: UISwitch!
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var showProfileLbl: UILabel!
    
    private var profilePrivacyString : String? = ""
    private var messagePrivacyString : String? = ""
    private var searchEngineString : String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func searchEngineSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
             self.searchEngineString = "\(1)"
        }else{
             self.searchEngineString = "\(0)"
        }
    }
    @IBAction func profilePrivacyPressed(_ sender: Any) {
        self.showAudience()
    }
    
    @IBAction func messagePrivacyPressed(_ sender: Any) {
        self.showDirectMessage()
    }
    func setupUI(){
        
        if AppInstance.instance.userProfile?.data?.searchEngines == "1" {
            self.searchEngineSwitch.isOn = true
            self.searchEngineString = "\(1)"
        }else{
            self.searchEngineSwitch.isOn = false
             self.searchEngineString = "\(0)"
        }
        
        self.profilePrivacyString = AppInstance.instance.userProfile?.data?.pPrivacy ?? ""
         self.messagePrivacyString = AppInstance.instance.userProfile?.data?.cPrivacy ?? ""

        self.showProfileLbl.text = NSLocalizedString("Show your profile in search engines", comment: "")
        self.privacyLbl.text = NSLocalizedString("Privacy", comment: "")
        self.audienceBtn.setTitle(NSLocalizedString("Who can view your profile?", comment: ""), for: UIControl.State.normal)
        self.directMessageBtn.setTitle(NSLocalizedString("Who can direct message you?", comment: ""), for: UIControl.State.normal)
        
        self.title = "Account Privacy"
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    @objc func Save(){
        self.updateAccountPrivacy()
    }
    
    func showAudience(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Who can view your profile?", comment: ""),
                                     rows: ["Everyone","Followers","Nobody"],
                                     initialSelection: Int((AppInstance.instance.userProfile?.data?.pPrivacy)!)!,
                                     doneBlock: { (picker, value, index) in
                                       self.profilePrivacyString = "\(value)"
                                        log.verbose("Index = \(value)")
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self.audienceBtn)
    }
    
    func showDirectMessage(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Who can direct message you?", comment: ""),
                                     rows: ["Everyone","People I follow"],
                                     initialSelection: Int((AppInstance.instance.userProfile?.data?.cPrivacy)!)!,
                                     doneBlock: { (picker, value, index) in
                                        self.messagePrivacyString = "\(value)"
                                        log.verbose("Index = \(value)")
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self.directMessageBtn)
    }
    private func updateAccountPrivacy(){
        self.showProgressDialog(text: "Loading...")
        log.verbose("self.profilePrivacyString  = \(self.profilePrivacyString ?? "")")
        log.verbose("self.messagePrivacyString  = \(self.messagePrivacyString ?? "")")
        let profilePrivacy = self.profilePrivacyString ?? ""
        let messagePrivacy = self.messagePrivacyString ?? ""
        let searchEngine = self.searchEngineString ?? ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProfileManger.instance.updateAccPrivacy(accessToken: accessToken, profilePrivacy: profilePrivacy, messagePrivacy: messagePrivacy, searchEngine: searchEngine, completionBlock: { (success, sessionError, error) in
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
