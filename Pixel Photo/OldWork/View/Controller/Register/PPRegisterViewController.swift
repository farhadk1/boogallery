//
//  PPRegisterViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
//import SwinjectStoryboard

class PPRegisterViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
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
    
    var onLoginClicked: (() -> Void)?
    
    var viewModel : RegisterViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.registerView.isRoundedRect(cornerRadius: 20)
        self.registerView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    func setupView(){
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
    }
    
    func setupRx(){
        
        self.emailTxtFld.rx.text.orEmpty.bind(to: (viewModel?.emailText)!).disposed(by: self.disposeBag)
        self.usernameTxtFld.rx.text.orEmpty.bind(to: (viewModel?.usernameTxt)!).disposed(by: self.disposeBag)
        self.passwordTxtFld.rx.text.orEmpty.bind(to: (viewModel?.passwordText)!).disposed(by: self.disposeBag)
        self.confirmPasswordTxtfld.rx.text.orEmpty.bind(to: (viewModel?.confirmPasswordText)!).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
//        self.viewModel?.toEditPage
//            .asDriver(onErrorJustReturn: false)
//            .filter({$0})
//            .drive(onNext : { value in
//                SwinjectStoryboard.defaultContainer.assembleEditProfile(mode : EDITPROFILEMODE.REG)
//                let sb = SwinjectStoryboard.create(name: "Profile",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPEditProfileViewControllerID") as! PPEditProfileViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
        self.registerView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.termsAndServiceComply()
            }).disposed(by: self.disposeBag)
        
        
        
        
        
        
        
//        self.termServicesBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                SwinjectStoryboard.defaultContainer.assembleWebView(url: "https://demo.pixelphotoscript.com/terms-of-use")
//                let sb = SwinjectStoryboard.create(name: "Main",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPWebViewControllerID") as! PPWebViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by:self.disposeBag)
        
        self.signInBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.onLoginClicked!()
            }).disposed(by:self.disposeBag)
        
    }
    
    func termsAndServiceComply(){
        let alert = UIAlertController(title: "Terms And Condition", message: "By registering to this application you agree to the bound of this application , Terms and Conditions if Use, all applicable laws and regulations, and agree that you are responsible for compilance with any applicable local laws. If you don't agree with any of these terms, you are prohibited to use or access to the application. The material contained in this application is protected by applicable copyright and trademark law.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (alert) in
            self.viewModel?.submitButton.accept(true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
