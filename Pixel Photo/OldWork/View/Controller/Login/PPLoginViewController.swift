////
////  PPLoginViewController.swift
////  Pixel Photo
////
////  Created by DoughouzLight on 25/12/2018.
////  Copyright © 2018 DoughouzLight. All rights reserved.
////
//
//import UIKit
//import RxCocoa
//import RxSwift
//import RxGesture
//import FBSDKLoginKit
//import GoogleSignIn
//
//class PPLoginViewController: UIViewController {
//    
//    var disposeBag = DisposeBag()
//    
//    @IBOutlet weak var orContainerView: UIView!
//    @IBOutlet weak var googleSignBtn: GIDSignInButton!
//    @IBOutlet weak var fbLoginBtn: UIButton!
//    @IBOutlet weak var forgotPasswordBtn: UIButton!
//    @IBOutlet weak var loginView: UIView!
//    @IBOutlet weak var registerBtn: UIButton!
//    @IBOutlet weak var emailTxtFld: UITextField!
//    @IBOutlet weak var passwordTxtFld: UITextField!
//    @IBOutlet weak var donthaveAccountLbl: UILabel!
//    
//    var onRegClicked: (() -> Void)?
//    
//    var viewModel : LoginViewModeling?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//        
//        setupView()
//        setupRx()
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        self.loginView.isRoundedRect(cornerRadius: 20)
//        self.loginView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
//    }
//    
//    func setupView(){
//        self.navigationController?.isNavigationBarHidden = false
//        self.title = NSLocalizedString("Sign In", comment: "")
//        
//        self.emailTxtFld.placeholder = NSLocalizedString("Email or Username", comment: "")
//        self.passwordTxtFld.placeholder = NSLocalizedString("Password", comment: "")
//        self.donthaveAccountLbl.text = NSLocalizedString("DON'T HAVE AN ACCOUNT?", comment: "")
//        self.forgotPasswordBtn.setTitle(NSLocalizedString("Forgot your password?", comment: ""), for: UIControl.State.normal)
//        self.registerBtn.setTitle(NSLocalizedString("Register", comment: ""), for: UIControl.State.normal)
//        
//        if !ControlSettings.EnableSocialLogin {
//            self.fbLoginBtn.isHidden = true
//            self.googleSignBtn.isHidden = true
//            self.orContainerView.isHidden = true
//        }else{
//            GIDSignIn.sharedInstance().delegate = self
//            GIDSignIn.sharedInstance().uiDelegate = self
//        }
//    }
//    
//    func setupRx(){
//        
//        self.emailTxtFld.rx.text.orEmpty.bind(to: (viewModel?.userNameText)!).disposed(by: self.disposeBag)
//        self.passwordTxtFld.rx.text.orEmpty.bind(to: (viewModel?.passwordText)!).disposed(by: self.disposeBag)
//        
//        self.fbLoginBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
////                self.fbUserLogin()
//            }).disposed(by:self.disposeBag)
//        
//        self.registerBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                self.onRegClicked!()
//            }).disposed(by:self.disposeBag)
//        
//        self.forgotPasswordBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                SwinjectStoryboard.defaultContainer.assembleForgotPassword()
//                let sb = SwinjectStoryboard.create(name: "Main",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPForgotPasswordViewControllerID") as! PPForgotPasswordViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by:self.disposeBag)
//        
//        
//        self.viewModel?.toDashboard
//            .asDriver(onErrorJustReturn: false)
//            .filter({$0})
//            .drive(onNext : { value in
//                let nextVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PPTabBarBaseViewControllerID") as! PPTabBarBaseViewController
//                nextVC.navigationController?.isNavigationBarHidden = false
//                self.present(nextVC, animated: true, completion: nil)
//            }).disposed(by: self.disposeBag)
//        
//        self.viewModel?.toEditPage
//            .asDriver(onErrorJustReturn: false)
//            .filter({$0})
//            .drive(onNext : { value in
//                SwinjectStoryboard.defaultContainer.assembleEditProfile(mode: EDITPROFILEMODE.EDIT)
//                let sb = SwinjectStoryboard.create(name: "Profile",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPEditProfileViewControllerID") as! PPEditProfileViewController
//                nextVC.navigationItem.hidesBackButton = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
//        
//        self.viewModel?.onErrorTrigger
//            .asDriver()
//            .filter({$0.0 != ""})
//            .drive(onNext : { arg in
//                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
//            }).disposed(by: self.disposeBag)
//        
//        self.loginView.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe({ _ in
//                self.viewModel?.submitButton.accept(true)
//            }).disposed(by: self.disposeBag)
//        
//    }
//    
//    
//    /*
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destination.
//     // Pass the selected object to the new view controller.
//     }
//     */
//    
//}
//
//extension PPLoginViewController  {
//    
////    func fbUserLogin(){
////        let aloginManager = LoginManager()
////        aloginManager.loginBehavior = LoginBehavior.native
////        aloginManager.logIn(permissions: [ .publicProfile, .email ], from: self) { loginResult in
////            print(loginResult)
////            switch loginResult {
////            case .failed(let error):
////                print(error)
////                break
////            case .cancelled:
////                print("User cancelled login.")
////                break
////            case .success( _, _ , let accessToken):
////                self.viewModel?.fbCred.accept(accessToken.authenticationToken)
////            }}
////    }
//    
//}
//
//extension PPLoginViewController : GIDSignInDelegate  , GIDSignInUIDelegate{
//    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let error = error {
//            print("\(error.localizedDescription)")
//        } else {
//            self.viewModel?.googleCred.accept(user.authentication.idToken)
//        }
//    }
//    
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
//              withError error: Error!) {
//        
//    }
//}
