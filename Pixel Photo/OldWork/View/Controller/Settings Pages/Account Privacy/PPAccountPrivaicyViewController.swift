//
//  PPAccountPrivaicyViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ActionSheetPicker_3_0

class PPAccountPrivaicyViewController: UIViewController {
    
    @IBOutlet weak var audienceBtn: UIButton!
    @IBOutlet weak var directMessageBtn: UIButton!
    @IBOutlet weak var searchEngineSwitch: UISwitch!
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var showProfileLbl: UILabel!
    
    var disposeBag = DisposeBag()
    
    var viewModel : SettingsViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        if self.viewModel?.privacySearchEngine.value == 1 {
            self.searchEngineSwitch.isOn = true
        }else{
            self.searchEngineSwitch.isOn = false
        }
        
        self.showProfileLbl.text = NSLocalizedString("Show your profile in search engines", comment: "")
        self.privacyLbl.text = NSLocalizedString("Privacy", comment: "")
        self.audienceBtn.setTitle(NSLocalizedString("Who can view your profile?", comment: ""), for: UIControl.State.normal)
        self.directMessageBtn.setTitle(NSLocalizedString("Who can direct message you?", comment: ""), for: UIControl.State.normal)
    }
    
    func setupRx(){
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.searchEngineSwitch
            .rx
            .controlEvent(.valueChanged)
            .withLatestFrom(searchEngineSwitch.rx.value)
            .subscribe({ bool in
                self.viewModel?.privacySearchEngine.accept(bool.element! ? 1 : 0)
            }).disposed(by: self.disposeBag)
        
        self.audienceBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.showAudience()
            }).disposed(by:self.disposeBag)
        
        self.directMessageBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.showDirectMessage()
            }).disposed(by:self.disposeBag)
    }
    
    
    func showAudience(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Who can view your profile?", comment: ""),
                                     rows: ["Everyone","Followers","Nobody"],
                                     initialSelection: (self.viewModel?.privacyProfile.value)!,
                                     doneBlock: { (picker, value, index) in
                                        self.viewModel?.privacyProfile.accept(value)
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self.audienceBtn)
    }
    
    func showDirectMessage(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Who can direct message you?", comment: ""),
                                     rows: ["Everyone","People I follow"],
                                     initialSelection: (self.viewModel?.privacyMessages.value)!,
                                     doneBlock: { (picker, value, index) in
                                        self.viewModel?.privacyMessages.accept(value)
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self.directMessageBtn)
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
