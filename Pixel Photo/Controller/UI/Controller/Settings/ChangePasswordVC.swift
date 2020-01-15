//
//  ChangePasswordVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class ChangePasswordVC: BaseVC {
    
    @IBOutlet weak var forgetPassBtn: UIButton!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var repeatPassTextField: UITextField!
    @IBOutlet weak var newPassTextFIeld: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    @IBAction func forgetPassPressed(_ sender: Any) {
    }
    
    func setupUI(){
        self.navigationController?.isNavigationBarHidden = false
        
        self.currentPassword.placeholder = NSLocalizedString("Current Password", comment: "")
        self.newPassTextFIeld.placeholder = NSLocalizedString("New Password", comment: "")
        self.repeatPassTextField.placeholder = NSLocalizedString("Repeat Password", comment: "")
        self.forgetPassBtn.setTitle(NSLocalizedString("If you forgot your password, you can reset it from here.", comment: ""), for: UIControl.State.normal)
        
        self.title = "General"
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    @objc func Save(){
        self.updatePassword()
    }
    private func updatePassword(){
        if appDelegate.isInternetConnected{
            
            if (self.currentPassword.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter current password."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (newPassTextFIeld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter new password."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }
            else if (repeatPassTextField.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please re-enter enter password."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.newPassTextFIeld.text != self.repeatPassTextField.text){
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Password do not match."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else{
                self.changePassword()
            }
        }
    }
    private func changePassword(){
        self.showProgressDialog(text: "Loading...")
        let currentPassword = self.currentPassword.text ?? ""
        let newPassword = self.newPassTextFIeld.text ?? ""
        let repeatPassword = self.repeatPassTextField.text ?? ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            
            ProfileManger.instance.changePassword(accessToken: accessToken, currentPassword: currentPassword, newPassword: newPassword, confirmPassword: repeatPassword, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
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
