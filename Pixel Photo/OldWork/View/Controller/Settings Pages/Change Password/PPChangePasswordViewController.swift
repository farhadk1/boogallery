//
//  PPChangePasswordViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPChangePasswordViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var repeatPasswordTxtFLd: UITextField!
    @IBOutlet weak var newPasswordTxtFld: UITextField!
    @IBOutlet weak var currentPasswordTxtFld: UITextField!
    @IBOutlet weak var forgotPassBtn: UIButton!
    
    private lazy var saveBtn : UIBarButtonItem = {
        return  UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }()
    
    var viewModel : SettingsViewModeling?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [saveBtn]
        
        self.currentPasswordTxtFld.placeholder = NSLocalizedString("Current Password", comment: "")
        self.newPasswordTxtFld.placeholder = NSLocalizedString("New Password", comment: "")
        self.repeatPasswordTxtFLd.placeholder = NSLocalizedString("Repeat Password", comment: "")
        self.forgotPassBtn.setTitle(NSLocalizedString("If you forgot your password, you can reset it from here.", comment: ""), for: UIControl.State.normal)
    }
    
    func setupRx(){
        
        self.currentPasswordTxtFld.rx.text.orEmpty.bind(to: (viewModel?.currentPasswordText)!).disposed(by: self.disposeBag)
        self.newPasswordTxtFld.rx.text.orEmpty.bind(to: (viewModel?.newPasswordText)!).disposed(by: self.disposeBag)
        self.repeatPasswordTxtFLd.rx.text.orEmpty.bind(to: (viewModel?.rePasswordText)!).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.saveBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.viewModel?.submit.accept(true)
            }).disposed(by:self.disposeBag)
        
//        self.forgotPassBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                SwinjectStoryboard.defaultContainer.assembleForgotPassword()
//                let sb = SwinjectStoryboard.create(name: "Main",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPForgotPasswordViewControllerID") as! PPForgotPasswordViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by:self.disposeBag)
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
