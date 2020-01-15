//
//  PPSettingsListViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 18/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import IoniconsSwift
import RxSwift
import RxCocoa

class PPSettingsListViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var disposeBag = DisposeBag()
    
    let list = [
        (NSLocalizedString("General", comment: ""),Ionicons.settings.image(20.0, color: UIColor.hexStringToUIColor(hex: "#4CAF50"))),
        (NSLocalizedString("Profile", comment: ""),Ionicons.androidContact.image(20.0, color: UIColor.hexStringToUIColor(hex: "#c83e40"))),
        (NSLocalizedString("Change Password", comment: ""),Ionicons.key.image(20.0, color: UIColor.hexStringToUIColor(hex: "#176764"))),
        (NSLocalizedString("Account Privacy", comment: ""),Ionicons.eye.image(20.0, color: UIColor.hexStringToUIColor(hex: "#ca4b8e"))),
        (NSLocalizedString("Notification", comment: ""),Ionicons.androidNotifications.image(20.0, color: UIColor.hexStringToUIColor(hex: "#795548"))),
        (NSLocalizedString("Blocked User", comment: ""),Ionicons.androidRemoveCircle.image(20.0, color: UIColor.hexStringToUIColor(hex: "#3f51b5"))),
        (NSLocalizedString("Delete Account", comment: ""),Ionicons.trashA.image(20.0, color: UIColor.hexStringToUIColor(hex: "#f44336"))),
        (NSLocalizedString("Logout", comment: ""),Ionicons.logOut.image(20.0, color: UIColor.hexStringToUIColor(hex: "#d50000"))),
        ]
    
    var alreadyInitialize = false
    
    var viewModel : SettingListViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.title = NSLocalizedString("Settings", comment: "")
        
        self.contentTblView.dataSource = self
        self.contentTblView.delegate = self
        
        self.contentTblView.register(UINib(nibName: "PPSettingsItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPSettingsItemTableViewCellID")
    }
    
    func setupRx(){
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                if !self.alreadyInitialize {
                    self.alreadyInitialize = true
                }
                self.viewModel?.isInitialize.accept(true)
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
extension PPSettingsListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPSettingsItemTableViewCellID") as! PPSettingsItemTableViewCell
        cell.titleLbl.text = self.list[indexPath.row].0
        cell.iconImgView.image = self.list[indexPath.row].1
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        if indexPath.row == 0 {
//            SwinjectStoryboard.defaultContainer.assembileSettingGeneral(user: (self.viewModel?.userItem)!, pageType: SETTINGPAGE.GENERAL)
//            let sb = SwinjectStoryboard.create(name: "Settings",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPGeneralViewControllerID") as! PPGeneralViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 1 {
//            SwinjectStoryboard.defaultContainer.assembleEditProfile(user:(self.viewModel?.userItem.value!)!,mode: EDITPROFILEMODE.EDIT)
//            let sb = SwinjectStoryboard.create(name: "Profile",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPEditProfileViewControllerID") as! PPEditProfileViewController
//            nextVC.goBack = true
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 2 {
//            SwinjectStoryboard.defaultContainer.assembileSettingChangePassword(user: (self.viewModel?.userItem)!, pageType: SETTINGPAGE.CHANGEPASSWORD)
//            let sb = SwinjectStoryboard.create(name: "Settings",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPChangePasswordViewControllerID") as! PPChangePasswordViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 3 {
//            SwinjectStoryboard.defaultContainer.assembileSettingAccountPrivacy(user: (self.viewModel?.userItem)!, pageType: SETTINGPAGE.ACCOUNTPRIVACY)
//            let sb = SwinjectStoryboard.create(name: "Settings",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPAccountPrivaicyViewControllerID") as! PPAccountPrivaicyViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 4 {
//            SwinjectStoryboard.defaultContainer.assembileSettingNotification(user: (self.viewModel?.userItem)!, pageType: SETTINGPAGE.NOTIFICATION)
//            let sb = SwinjectStoryboard.create(name: "Settings",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPSettingNotificationViewControllerID") as! PPSettingNotificationViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 5 {
//            SwinjectStoryboard.defaultContainer.assembileSettingBlockedUser(user: (self.viewModel?.userItem)!, pageType: SETTINGPAGE.BLOCKEDUSER)
//            let sb = SwinjectStoryboard.create(name: "Settings",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPBlockedUsersViewControllerID") as! PPBlockedUsersViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 6 {
//            SwinjectStoryboard.defaultContainer.assembileSettingDeleteAccount(user: (self.viewModel?.userItem)!, pageType: SETTINGPAGE.BLOCKEDUSER)
//            let sb = SwinjectStoryboard.create(name: "Settings",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPDeleteAccountViewControllerID") as! PPDeleteAccountViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }else if indexPath.row == 7 {
//            self.logout()
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
