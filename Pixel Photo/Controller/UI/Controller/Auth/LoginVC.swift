//
//  LoginVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Async
import PixelPhotoSDK

class LoginVC: BaseVC {
    
    @IBOutlet weak var orContainerView: UIView!
    @IBOutlet weak var googleSignBtn: GIDSignInButton!
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var donthaveAccountLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.loginView.isRoundedRect(cornerRadius: 20)
        self.loginView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    @IBAction func facebookPressed(_ sender: Any) {
        self.facebookLogin()
    }
    
    @IBAction func forgetPassPressed(_ sender: Any) {
        let vc = R.storyboard.main.forgetPasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func registerPressed(_ sender: Any) {
        let vc = R.storyboard.main.signUpVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func setupUI(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationItem.hidesBackButton = true

        self.title = NSLocalizedString("Sign In", comment: "")
        
        self.donthaveAccountLbl.text = NSLocalizedString("DON'T HAVE AN ACCOUNT?", comment: "")
        self.forgotPasswordBtn.setTitle(NSLocalizedString("Forgot your password?", comment: ""), for: UIControl.State.normal)
        self.registerBtn.setTitle(NSLocalizedString("Register", comment: ""), for: UIControl.State.normal)
        
        if !ControlSettings.EnableSocialLogin {
            self.fbLoginBtn.isHidden = true
            self.googleSignBtn.isHidden = true
            self.orContainerView.isHidden = true
        }else{
            self.fbLoginBtn.isHidden = false
            self.googleSignBtn.isHidden = false
            self.orContainerView.isHidden = false
        }
        let Logintap = UITapGestureRecognizer(target: self, action: #selector(self.loginTapped(_:)))
        self.loginView.isUserInteractionEnabled = true
        self.loginView.addGestureRecognizer(Logintap)
        
        let googletap = UITapGestureRecognizer(target: self, action: #selector(self.googleTapped(_:)))
        self.googleSignBtn.isUserInteractionEnabled = true
        self.googleSignBtn.addGestureRecognizer(googletap)
    }
    @objc func loginTapped(_ sender: UITapGestureRecognizer) {
        loginPressed()
    }
    @objc func googleTapped(_ sender: UITapGestureRecognizer) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    private func loginPressed(){
        if appDelegate.isInternetConnected{
            
            if (self.emailTxtFld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter username."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (passwordTxtFld.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter password."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else{
                
                self.showProgressDialog(text: "Loading...")
                let email = self.emailTxtFld.text ?? ""
                let password = self.passwordTxtFld.text ?? ""
                let deviceId = self.deviceID ?? ""
                Async.background({
                    UserManager.instance.authenticateUser(userName: email, password: password, DeviceId: "", completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog{
                                    
                                    log.verbose("Success = \(success?.data?.accessToken ?? "")")
                                    AppInstance.instance.getUserSession()
                                    AppInstance.instance.fetchUserProfile()
                                    UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                    
                                    let dashboardNav =  R.storyboard.dashboard.tabbarVC()
                                    self.present(dashboardNav!, animated: true, completion: nil)
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
        }else{
            self.dismissProgressDialog {
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    private func facebookLogin(){
        if Connectivity.isConnectedToNetwork(){
            let fbLoginManager : LoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
                if (error == nil){
                    self.showProgressDialog(text: "Loading...")
                    let fbloginresult : LoginManagerLoginResult = result!
                    if (result?.isCancelled)!{
                        self.dismissProgressDialog{
                            log.verbose("result.isCancelled = \(result?.isCancelled ?? false)")
                        }
                        return
                    }
                    if fbloginresult.grantedPermissions != nil {
                        if(fbloginresult.grantedPermissions.contains("email")) {
                            if((AccessToken.current) != nil){
                                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                    if (error == nil){
                                        let dict = result as! [String : AnyObject]
                                        log.debug("result = \(dict)")
                                        guard (dict["first_name"] as? String) != nil else {return}
                                        guard (dict["last_name"] as? String) != nil else {return}
                                        guard (dict["email"] as? String) != nil else {return}
                                        let accessToken = AccessToken.current?.tokenString ?? ""
                                        Async.background({
                                            UserManager.instance.socialLogin(provider: "facebook", accessToken: accessToken, googleApiKey: "", completionBlock: { (success, sessionError,error) in
                                                if success != nil{
                                                    Async.main{
                                                        self.dismissProgressDialog{
                                                            log.verbose("Success = \(success?.code ?? "")")
                                                            AppInstance.instance.getUserSession()
                                                            AppInstance.instance.fetchUserProfile()
                                                            let vc = R.storyboard.dashboard.tabbarVC()
                                                            self.present(vc!, animated: true, completion: nil)
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
                                        log.verbose("FBSDKAccessToken.current() = \(AccessToken.current?.tokenString ?? "")")
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    private func googleLogin(accessToken:String){
        if appDelegate.isInternetConnected{
                self.showProgressDialog(text: "Loading...")
            Async.background({
                UserManager.instance.socialLogin(provider: "google", accessToken: accessToken, googleApiKey: "", completionBlock: { (success, sessionError,error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog{
                                log.verbose("Success = \(success?.code ?? "")")
                                AppInstance.instance.getUserSession()
                                AppInstance.instance.fetchUserProfile()
                                //                                                            let vc = R.storyboard.login.getStartedVC()
                                //                                                            self.navigationController?.pushViewController(vc!, animated: true)
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
            
        }else{
            self.dismissProgressDialog {
                
                let securityAlertVC = R.storyboard.popup.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
        
    }
}


extension LoginVC : GIDSignInDelegate  , GIDSignInUIDelegate{

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
           self.googleLogin(accessToken: user.authentication.accessToken)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {

    }
}
