//
//  PPGeneralViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import ActionSheetPicker_3_0

class PPGeneralViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var genderTxtFld: UITextField!
    
    var viewModel : SettingsViewModeling?
    
    private lazy var saveBtn : UIBarButtonItem = {
        return  UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }()
    
    var genderSelection = ["Male","Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [saveBtn]
        
        self.usernameTxtFld.placeholder = NSLocalizedString("Username", comment: "")
        self.emailTxtFld.placeholder = NSLocalizedString("Email", comment: "")
        self.genderTxtFld.placeholder = NSLocalizedString("Gender", comment: "")
        
        self.genderTxtFld.delegate = self
        
        self.emailTxtFld.text = viewModel?.emailText.value
        self.usernameTxtFld.text = viewModel?.userNameText.value
        self.genderTxtFld.text = viewModel?.genderText.value
    }
    
    func setupRx(){
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.emailTxtFld.rx.text.orEmpty.bind(to: (viewModel?.emailText)!).disposed(by: self.disposeBag)
        self.usernameTxtFld.rx.text.orEmpty.bind(to: (viewModel?.userNameText)!).disposed(by: self.disposeBag)
        self.genderTxtFld.rx.text.orEmpty.bind(to: (viewModel?.genderText)!).disposed(by: self.disposeBag)
        
        self.saveBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.viewModel?.submit.accept(true)
            }).disposed(by:self.disposeBag)
    }
    
    func showGenderSelection(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Gender", comment: ""),
                                     rows: genderSelection,
                                     initialSelection: 0,
                                     doneBlock: { (picker, value, index) in
                                        
                                        if value == 0 {
                                            self.genderTxtFld.text = "Male"
                                            self.viewModel?.genderText.accept("Male")
                                        }else {
                                            self.genderTxtFld.text = "Female"
                                            self.viewModel?.genderText.accept("Female")
                                        }
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self.genderTxtFld)
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

extension PPGeneralViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showGenderSelection()
        return false
    }
}
