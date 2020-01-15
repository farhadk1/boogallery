//
//  PPEditProfileViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 27/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPEditProfileViewController: UIViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var disposeBag = DisposeBag()
    
    var viewModel : EditProfileViewModeling?
    
    var goBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPInputTextFieldItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPInputTextFieldItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPMyProfileCaptureProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "PPMyProfileCaptureProfileTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPSubmitButtonItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPSubmitButtonItemTableViewCellID")
    }
    
    func setupRx(){
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.goToSuggestionUserPage
            .filter({$0})
            .asDriver(onErrorJustReturn: false)
            .drive(onNext : { _ in
                
                if self.goBack {
                    self.navigationController?.popViewController(animated: true)
                }else{
//                    SwinjectStoryboard.defaultContainer.assembleUserSuggestion()
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PPSuggestionUserViewControllerID") as! PPSuggestionUserViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func showImagePicker(){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

extension PPEditProfileViewController : UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPMyProfileCaptureProfileTableViewCellID") as! PPMyProfileCaptureProfileTableViewCell
//            cell.bind(vc: self, viewModel: self.viewModel!)
            return cell
        }else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPSubmitButtonItemTableViewCellID") as! PPSubmitButtonItemTableViewCell
//            cell.bind(viewModel: self.viewModel!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPInputTextFieldItemTableViewCellID") as! PPInputTextFieldItemTableViewCell
//        cell.bind(row: indexPath.row,viewModel:self.viewModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension PPEditProfileViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let profileImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.viewModel?.profileImage.accept(profileImg)
        self.viewModel?.profileUrl.accept( FileManager.default.saveImage(image: profileImg!))
        picker.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
}
