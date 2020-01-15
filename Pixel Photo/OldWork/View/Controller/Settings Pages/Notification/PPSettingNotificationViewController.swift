//
//  PPNotificationViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 22/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PPSettingNotificationViewController: UIViewController {
    
    var viewModel : SettingsViewModeling?
    
    @IBOutlet weak var likeSwitch: UISwitch!
    @IBOutlet weak var commentSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    @IBOutlet weak var mentionSwitch: UISwitch!
    
    @IBOutlet weak var receiveNotificationLbl: UILabel!
    @IBOutlet weak var likedMyPostLbl: UILabel!
    @IBOutlet weak var commentedOnmyPostLbl: UILabel!
    @IBOutlet weak var followedMeLbl: UILabel!
    @IBOutlet weak var mentionedLbl: UILabel!
    
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.receiveNotificationLbl.text = NSLocalizedString("Receive Notification when some one", comment: "")
        self.likedMyPostLbl.text = NSLocalizedString("Liked my post", comment: "")
        self.commentedOnmyPostLbl.text = NSLocalizedString("Commented on my post", comment: "")
        self.followedMeLbl.text = NSLocalizedString("Followed me", comment: "")
        self.mentionedLbl.text = NSLocalizedString("Mentioned me", comment: "")
        
        
        if self.viewModel?.notificationLike.value == 1 {
            self.likeSwitch.isOn = true
        }else{
            self.likeSwitch.isOn = false
        }
        
        if self.viewModel?.notificationComment.value == 1 {
            self.commentSwitch.isOn = true
        }else{
            self.commentSwitch.isOn = false
        }
        
        if self.viewModel?.notificationFollow.value == 1 {
            self.followSwitch.isOn = true
        }else{
            self.followSwitch.isOn = false
        }
        
        if self.viewModel?.notificationMention.value == 1 {
            self.mentionSwitch.isOn = true
        }else{
            self.mentionSwitch.isOn = false
        }
        
    }
    
    func setupRx(){
        
        self.likeSwitch
            .rx
            .controlEvent(.valueChanged)
            .withLatestFrom(likeSwitch.rx.value)
            .subscribe({ bool in
                self.viewModel?.notificationLike.accept(bool.element! ? 1 : 0)
            }).disposed(by: self.disposeBag)
        
        self.commentSwitch
            .rx
            .controlEvent(.valueChanged)
            .withLatestFrom(likeSwitch.rx.value)
            .subscribe({ bool in
                self.viewModel?.notificationComment.accept(bool.element! ? 1 : 0)
            }).disposed(by: self.disposeBag)
        
        self.followSwitch
            .rx
            .controlEvent(.valueChanged)
            .withLatestFrom(likeSwitch.rx.value)
            .subscribe({ bool in
                self.viewModel?.notificationFollow.accept(bool.element! ? 1 : 0)
            }).disposed(by: self.disposeBag)
        
        self.mentionSwitch
            .rx
            .controlEvent(.valueChanged)
            .withLatestFrom(likeSwitch.rx.value)
            .subscribe({ bool in
                self.viewModel?.notificationMention.accept(bool.element! ? 1 : 0)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
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
