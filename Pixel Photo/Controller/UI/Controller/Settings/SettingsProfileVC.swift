//
//  SettingsProfileVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 24/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class SettingsProfileVC: BaseVC {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var googleTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var commingFrom:String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if commingFrom == "profile"{
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    private func setupUI(){
        
        self.title = "Profile"
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
        self.googleTextField.text = AppInstance.instance.userProfile?.data?.google ?? ""
        self.facebookTextField.text = AppInstance.instance.userProfile?.data?.facebook ?? ""
        self.firstNameTextField.text = AppInstance.instance.userProfile?.data?.fname ?? ""
        self.lastNameTextField.text = AppInstance.instance.userProfile?.data?.lname ?? ""
        self.aboutTextField.text = AppInstance.instance.userProfile?.data?.about ?? ""
        self.twitterTextField.text = AppInstance.instance.userProfile?.data?.twitter ?? ""
        
    }
    @objc func Save(){
        self.updateProfile()
    }
    private func updateProfile(){
        self.showProgressDialog(text: "Loading...")
        
        let firstname = self.firstNameTextField.text ?? ""
        let lastname = lastNameTextField.text ?? ""
        let about = self.aboutTextField.text ?? ""
        let facebook = facebookTextField.text ?? ""
        let google = self.googleTextField.text ?? ""
        let twitter = twitterTextField.text ?? ""
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProfileManger.instance.updateEditProfile(accessToken: accessToken, firsName: firstname, lastName: lastname, about: about, facebook: facebook, google: google, twitter: twitter, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            AppInstance.instance.fetchUserProfile()
                            self.view.makeToast(success?.message ?? "")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog { self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            })
        })
    }
}
