//
//  PPDeleteAccountViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BEMCheckBox
import RxGesture

class PPDeleteAccountViewController: PPBaseViewController {
    
    var viewModel : SettingsViewModeling?
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var deleteAccountView: GradientView!
    @IBOutlet weak var deleteAccountCheckBox: BEMCheckBox!
    @IBOutlet weak var deleteAccountLbl: UILabel!
    @IBOutlet weak var removeAccountLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        self.passwordTxtFld.placeholder = NSLocalizedString("Password", comment: "")
        self.deleteAccountLbl.text = NSLocalizedString("Delete Account", comment: "")
        self.removeAccountLbl.text = NSLocalizedString("Remove Account", comment: "")
        
    }
    
    func setupRx(){
        
        self.passwordTxtFld.rx.text.orEmpty.bind(to: (viewModel?.currentPasswordText)!).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        
        self.deleteAccountView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                
                if self.deleteAccountCheckBox.on {
                    self.viewModel?.submit.accept(true)
                }else{
                    AlertDialog.shared.promptForWithoutObservable(title: NSLocalizedString("Delete Account", comment: ""),NSLocalizedString("Check Delete", comment: ""), actionTitle: "OK", vc: self)
                }
                
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.logout
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.logout()
            }).disposed(by: self.disposeBag)
        
    }
    
}
