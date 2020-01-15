//
//  SettingVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import UIKit
import IoniconsSwift
import PixelPhotoSDK

class SettingVC: BaseVC {
    
    @IBOutlet weak var contentTblView: UITableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    func setupUI(){
        self.title = NSLocalizedString("Settings", comment: "")
        
        self.contentTblView.register(R.nib.ppSettingsItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppSettingsItemTableViewCellID.identifier)
    }
}
extension SettingVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ppSettingsItemTableViewCellID.identifier) as! PPSettingsItemTableViewCell
        cell.titleLbl.text = self.list[indexPath.row].0
        cell.iconImgView.image = self.list[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let vc = R.storyboard.settings.generalVC()
            self.pushToVC(vc: vc!)
        }else if indexPath.row == 1 {
            let vc = R.storyboard.settings.settingsProfileVC()
            self.pushToVC(vc: vc!)
        }else if indexPath.row == 2 {
            let vc = R.storyboard.settings.changePasswordVC()
            self.pushToVC(vc: vc!)
        }else if indexPath.row == 3 {
            let vc = R.storyboard.settings.accountPrivacyVC()
            self.pushToVC(vc: vc!)
        }else if indexPath.row == 4 {
            let vc = R.storyboard.settings.notificationSettingsVC()
            self.pushToVC(vc: vc!)
        }else if indexPath.row == 5 {
            let vc = R.storyboard.settings.blockUserVC()
            self.pushToVC(vc: vc!)
        }else if indexPath.row == 6 {
            let vc = R.storyboard.settings.deleteAccountVC()
            self.pushToVC(vc: vc!)
            
        }else if indexPath.row == 7 {
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout", preferredStyle: .alert)
            let logout = UIAlertAction(title: "Logout", style: .default) { (action) in
                UserDefaults.standard.clearUserDefaults()
                let vc = R.storyboard.main.mainNav()
                self.appDelegate.window?.rootViewController = vc
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(logout)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func pushToVC(vc:UIViewController){
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
