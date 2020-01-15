//
//  ForgetPassword.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class ForgetPasswordVC: BaseVC {
    
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var pleaseEnterLbl: UILabel!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.forgotPasswordBtn.isRoundedRect(cornerRadius: self.forgotPasswordBtn.frame.height / 2)
        self.forgotPasswordBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    func setupUI(){
        self.navigationController?.isNavigationBarHidden = false
           self.navigationController?.navigationItem.hidesBackButton = true
        self.title = NSLocalizedString("Forgot Password", comment: "")
        self.pleaseEnterLbl.text = NSLocalizedString("Please enter your email address. We will send you a link to reset password.", comment: "")
        self.emailTxtFld.placeholder = NSLocalizedString("Email", comment: "")
        
        let forgetPasstap = UITapGestureRecognizer(target: self, action: #selector(self.forgetPasswordTapped(_:)))
        self.forgotPasswordBtn.isUserInteractionEnabled = true
        self.forgotPasswordBtn.addGestureRecognizer(forgetPasstap)
        
        
    }
    @objc func forgetPasswordTapped(_ sender: UITapGestureRecognizer) {
        send()
    }
    private func send(){
        self.showProgressDialog(text: "Loading...")
        let email = emailTxtFld.text ?? ""
        Async.background({
            UserManager.instance.forgetPassword(email: email, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("userList = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            
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
    }
}
