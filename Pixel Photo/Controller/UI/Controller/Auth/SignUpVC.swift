//
//  SignUpVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class SignUpVC: BaseVC {
    
    @IBOutlet weak var createAccountLbl: UILabel!
    @IBOutlet weak var termServicesBtn: UIButton!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var confirmPasswordTxtfld: UITextField!
    @IBOutlet weak var registeringTermsLbl: UILabel!
    @IBOutlet weak var alreadyHaveAnAccountLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.registerView.isRoundedRect(cornerRadius: 20)
        self.registerView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        let vc = R.storyboard.main.loginVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func TermAndServicesPressed(_ sender: Any) {
    }
    func setupUI(){
        self.navigationController?.isNavigationBarHidden = false
        self.title = NSLocalizedString("Register", comment: "")
        
        self.emailTxtFld.placeholder = NSLocalizedString("Email", comment: "")
        self.usernameTxtFld.placeholder = NSLocalizedString("Username", comment: "")
        self.passwordTxtFld.placeholder = NSLocalizedString("Password", comment: "")
        self.confirmPasswordTxtfld.placeholder = NSLocalizedString("Confirm Password", comment: "")
        self.createAccountLbl.text = NSLocalizedString("CREATE AN ACCOUNT", comment: "")
        self.registeringTermsLbl.text = NSLocalizedString("BY REGISTERING YOU AGREE TO OUR", comment: "")
        self.termServicesBtn.setTitle(NSLocalizedString("TERMS AND SERVICES", comment: ""), for: UIControl.State.normal)
        self.alreadyHaveAnAccountLbl.text = NSLocalizedString("ALREADY HAVE AN ACCOUNT?", comment: "")
        self.signInBtn.setTitle(NSLocalizedString("SIGN IN", comment: ""), for: UIControl.State.normal)
        
        let registertap = UITapGestureRecognizer(target: self, action: #selector(self.registerTapped(_:)))
        self.registerView.isUserInteractionEnabled = true
        self.registerView.addGestureRecognizer(registertap)
    }
    
    @objc func registerTapped(_ sender: UITapGestureRecognizer) {
        registerPressed()
    }
    
    private func registerPressed(){
        if appDelegate.isInternetConnected{
            if (self.emailTxtFld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter email."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.usernameTxtFld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter username."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.passwordTxtFld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter password."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.confirmPasswordTxtfld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter confirm password."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.passwordTxtFld.text != self.confirmPasswordTxtfld.text){
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Password do not match."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if !((emailTxtFld.text?.isEmail)!){
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Email is badly formatted."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }
            else{
                let alert = UIAlertController(title: "", message: "By registering you agree to our terms of service", preferredStyle: .alert)
                let okay = UIAlertAction(title: "OKAY", style: .default) { (action) in
                    self.registerPressedfunc()
                }
                let termsOfService = UIAlertAction(title: "TERMS OF SERVICE", style: .default) { (action) in
                    let url = URL(string: "https://deepsoundscript.com/terms/terms")!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("Open url : \(success)")
                        })
                    }
                }
                let privacy = UIAlertAction(title: "PRIVACY", style: .default) { (action) in
                    let url = URL(string: "https://deepsoundscript.com/terms/privacy")!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("Open url : \(success)")
                        })
                    }
                }
                alert.addAction(termsOfService)
                alert.addAction(privacy)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error "
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    private func registerPressedfunc(){
        self.showProgressDialog(text: "Loading...")
        let username = self.usernameTxtFld.text ?? ""
        let email = self.emailTxtFld.text ?? ""
        let password = self.passwordTxtFld.text ?? ""
        let confirmPassword = self.confirmPasswordTxtfld.text ?? ""
        Async.background({
            UserManager.instance.registerUser(userName: username, password: password, email: email, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        
                        self.dismissProgressDialog{
                            log.verbose("Success = \(success?.data?.accessToken ?? "")")
                            AppInstance.instance.getUserSession()
                            AppInstance.instance.fetchUserProfile()
                            UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                            let vc = R.storyboard.profile.editProfileVC()
                            self.navigationController?.pushViewController(vc!, animated: true)
                            self.view.makeToast("Login Successfull!!")
                        }
                        
                    }
                    
                }else if sessionError != nil{
                    Async.main{
                        
                        self.dismissProgressDialog {
                            log.verbose("session Error = \(sessionError?.errors?.errorText ?? "")")
                            let securityAlertVC = R.storyboard.popup.securityPopupVC()
                            securityAlertVC?.titleText  = "Security"
                            securityAlertVC?.errorText = sessionError?.errors?.errorText ?? ""
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    }
                    
                }else {
                    Async.main({
                        
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            let securityAlertVC = R.storyboard.popup.securityPopupVC()
                            securityAlertVC?.titleText  = "Security"
                            securityAlertVC?.errorText = error?.localizedDescription ?? ""
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    })
                }
            })
        })
    }  
}
