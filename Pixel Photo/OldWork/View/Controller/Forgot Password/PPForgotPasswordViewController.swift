//
//  PPForgotPasswordViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

class PPForgotPasswordViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    

    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var pleaseEnterLbl: UILabel!

    
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    var viewModel : ForgotPasswordModeling?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        

        self.forgotPasswordBtn.isRoundedRect(cornerRadius: self.forgotPasswordBtn.frame.height / 2)
        self.forgotPasswordBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    
    func setupView(){
        self.navigationController?.isNavigationBarHidden = false
        self.title = NSLocalizedString("Forgot Password", comment: "")
        self.pleaseEnterLbl.text = NSLocalizedString("Please enter your email address. We will send you a link to reset password.", comment: "")
        self.emailTxtFld.placeholder = NSLocalizedString("Email", comment: "")

    }
 
    func setupRx(){

        self.emailTxtFld.rx.text.orEmpty.bind(to: (viewModel?.emailText)!).disposed(by: self.disposeBag)

        self.forgotPasswordBtn.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.viewModel?.submitButton.accept(true)
            }).disposed(by: self.disposeBag)

        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
    }
    
    

    
}
