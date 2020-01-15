//
//  EditProfileVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 21/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class EditProfileVC: BaseVC {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var googleTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var coverImageVar:UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    private func setupUI(){
        self.title = "edit Profile"
        let Save = UIBarButtonItem(title: "Save & Continue", style: .done, target: self, action: Selector("SaveAndContinue"))
        self.navigationItem.rightBarButtonItem = Save
        
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        cameraView.isUserInteractionEnabled = true
        cameraView.addGestureRecognizer(profileImageTapGestureRecognizer)
        
    }
    @objc func SaveAndContinue(){
        updateUserProfile()
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imageStatus = false
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imageStatus = false
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    private func updateUserProfile(){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let firstname = self.firstNameTextField.text ?? ""
        let lastname = self.lastNameTextField.text ?? ""
        let gender = self.genderTextField.text  ?? ""
        let about = self.aboutTextField.text ?? ""
        let facebook = self.facebookTextField.text ?? ""
        let google = self.googleTextField.text ?? ""
       
        Async.background({
            if self.avatarImage == nil{
                ProfileManger.instance.updateUserProfile(accessToken: accessToken, firstname: firstname, lastname: lastname, gender: gender, about: about, facebook: facebook, google: google, avatar_data: nil, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile()
                                let vc = R.storyboard.profile.userSuggestionVC()
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            }
                            
                        })
                        
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                        
                    }
                })
            }else{
                    let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                ProfileManger.instance.updateUserProfile(accessToken: accessToken, firstname: firstname, lastname: lastname, gender: gender, about: about, facebook: facebook, google: google, avatar_data: avatarData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile()
                            }
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            }
                            
                        })
                        
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                        
                    }
                })
            }
            
        })
        
        
    }
}
extension  EditProfileVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
       
            self.profileImage.image = image
            self.avatarImage  = image ?? nil
        
        self.dismiss(animated: true, completion: nil)
    }
}
