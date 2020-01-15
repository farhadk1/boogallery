//
//  DeleteAccountVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import BEMCheckBox
import Async
import PixelPhotoSDK

class DeleteAccountVC: BaseVC {
    
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var deleteAccountView: GradientView!
    @IBOutlet weak var deleteAccountCheckBox: BEMCheckBox!
    @IBOutlet weak var deleteAccountLbl: UILabel!
    @IBOutlet weak var removeAccountLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI(){
        self.passwordTxtFld.placeholder = NSLocalizedString("Password", comment: "")
        self.deleteAccountLbl.text = NSLocalizedString("Delete Account", comment: "")
        self.removeAccountLbl.text = NSLocalizedString("Remove Account", comment: "")
        let removeAccountap = UITapGestureRecognizer(target: self, action: #selector(self.removeAccountTapped(_:)))
        self.deleteAccountView.isUserInteractionEnabled = true
        self.deleteAccountView.addGestureRecognizer(removeAccountap)
        
    }

    @objc func removeAccountTapped(_ sender: UITapGestureRecognizer) {
        self.deleteAccount()
    }
    private func deleteAccount(){
        if appDelegate.isInternetConnected{
            if self.deleteAccountCheckBox.on {
            }else{
                if (self.passwordTxtFld.text?.isEmpty)!{
                    let securityAlertVC = R.storyboard.popup.securityPopupVC()
                    securityAlertVC?.titleText  = "Security"
                    securityAlertVC?.errorText = "Please enter current password."
                    self.present(securityAlertVC!, animated: true, completion: nil)
                }else{
                    self.deleteAccounApi()
                }
            }
        }
    }
    private func deleteAccounApi(){
        self.showProgressDialog(text: "Loading...")
        let password = self.passwordTxtFld.text ?? ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProfileManger.instance.removeAccount(accessToken: accessToken, password: password, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            self.logout()
                            
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
    private func logout(){
            UserDefaults.standard.clearUserDefaults()
            let vc = R.storyboard.main.mainNav()
            appDelegate.window?.rootViewController = vc
    }
}

