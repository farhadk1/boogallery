//
//  PPMyProfileViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import PixelPhotoFramework

class PPMyProfileViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var shouldUpdate = true
    
    private let titleText = UIBarButtonItem(title: "My Profile", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    
    private lazy var settingsBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        btn.setImage(UIImage(named:"ic_settings"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        btn.setImage(UIImage(named:"ic_back_black"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    
    var viewModel : ProfileViewModeling?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.navigationController?.isNavigationBarHidden = false
        
        if PixelPhotoSDK.shared.getMyUserID() == self.viewModel?.userID {
            let settingsBtnItem = UIBarButtonItem(customView: settingsBtn)
            navigationItem.rightBarButtonItems = [settingsBtnItem]
        }else{
            let backBtnItem = UIBarButtonItem(customView: backBtn)
            navigationItem.leftBarButtonItems = [backBtnItem]
        }
        
        
        
        self.navigationItem.title = Bundle.mainInfoDictionary(key: kCFBundleNameKey)
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPMyProfileITemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPMyProfileITemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPNormalVerticalCollectionViewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPNormalVerticalCollectionViewItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPProfileItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPProfileItemTableViewCellID")
        
        self.reloadDataAndView()
        
    }
    
    func setupRx(){
        
        self.backBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .filter({self.viewModel?.userItem.value != nil})
            .subscribe({ _ in
                self.navigationController?.popViewController(animated: true)
            }).disposed(by:self.disposeBag)
        
        self.viewModel?.showImageMenu
            .asDriver()
            .filter({ $0 != false })
            .drive(onNext : { value in
                self.showImagePicker()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.goBack
            .asDriver()
            .filter({ $0 != false })
            .drive(onNext : { value in
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: self.disposeBag)
        
//        self.viewModel?.showPost
//            .asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                self.shouldUpdate = true
//                SwinjectStoryboard.defaultContainer.assemblePostItem(item: (self.viewModel?.showPost)!.value!)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPPostItemViewControllerID") as! PPPostItemViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
        
//        self.viewModel?.messageuser
//            .asDriver(onErrorJustReturn: nil)
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                self.shouldUpdate = true
//                SwinjectStoryboard.defaultContainer.assembleChatItem(user: value!)
//                let sb = SwinjectStoryboard.create(name: "Chat",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPChatViewControllerID") as! PPChatViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//
//            }).disposed(by: self.disposeBag)
        
        
//        self.settingsBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .filter({self.viewModel?.userItem.value != nil})
//            .subscribe({ _ in
//                self.shouldUpdate = true
//                SwinjectStoryboard.defaultContainer.assembleSettingsList(user: (self.viewModel?.userItem.value)!)
//                let sb = SwinjectStoryboard.create(name: "Settings",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPSettingsListViewControllerID") as! PPSettingsListViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by:self.disposeBag)
        
        self.rx.viewDidAppear
            .asDriver(onErrorJustReturn: false)
            .drive(onNext : { _ in
                if self.shouldUpdate {
                    self.viewModel?.isInitialize.accept(true)
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.postItems
            .asDriver()
            .drive(onNext : { _ in
                self.reloadDataAndView()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.userItem
            .asDriver()
            .drive(onNext : { _ in
                self.reloadDataAndView()
            }).disposed(by: self.disposeBag)
        
    }
    
    func reloadDataAndView(){
        let contentOffset = self.contentTblView.contentOffset
        self.contentTblView.reloadData()
        self.contentTblView.layoutIfNeeded()
        self.contentTblView.setContentOffset(contentOffset, animated: false)
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
            self.shouldUpdate = false
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
        self.shouldUpdate = false
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
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
extension PPMyProfileViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let profileImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.viewModel?.profileImage.accept(profileImg)
        self.viewModel?.profileUrl.accept(FileManager.default.saveImage(image: profileImg!))
        
        //        if picker.sourceType == .camera {
        //
        //        }else{
        //            if #available(iOS 11.0, *) {
        //                let profileImgURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        //                self.viewModel?.profileUrl.accept((profileImgURL?.absoluteString)!)
        //            } else {
        //                // Fallback on earlier versions
        //                let profileImgURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        //                self.viewModel?.profileUrl.accept((profileImgURL?.absoluteString)!)
        //            }
        //
        //        }
        
        picker.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
}


extension PPMyProfileViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        if indexPath.row == 0 {
//
//            if self.viewModel?.userID == PixelPhotoSDK.shared.getMyUserID() {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "PPMyProfileITemTableViewCellID") as! PPMyProfileITemTableViewCell
//                cell.bind(viewModel: self.viewModel!)
//                cell.onEditProfile = {
//                    SwinjectStoryboard.defaultContainer.assembleEditProfile(user:(self.viewModel?.userItem.value!)!,mode:EDITPROFILEMODE.EDIT)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PPEditProfileViewControllerID") as! PPEditProfileViewController
//                    nextVC.goBack = true
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                cell.onFollowingClicked = {
//                    SwinjectStoryboard.defaultContainer.assembleFollowerFollowing(type: PROFILEMODE.FOLLOWING, userID: (self.viewModel?.userID!)!)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PPFollowerFollowingViewControllerID") as! PPFollowerFollowingViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                cell.onFollowerClicked = {
//                    SwinjectStoryboard.defaultContainer.assembleFollowerFollowing(type: PROFILEMODE.FOLLOWER, userID:  (self.viewModel?.userID!)!)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PPFollowerFollowingViewControllerID") as! PPFollowerFollowingViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                cell.onFavoriteClicked = {
//                    SwinjectStoryboard.defaultContainer.assembleFavoritePost(userID: (self.viewModel?.userID!)!)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PCFavoritesViewControllerID") as! PCFavoritesViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                return cell
//            }else{
//                let cell = tableView.dequeueReusableCell(withIdentifier: "PPProfileItemTableViewCellID") as! PPProfileItemTableViewCell
//                cell.bind(viewModel: self.viewModel!)
//                cell.onFollowingClicked = {
//                    SwinjectStoryboard.defaultContainer.assembleFollowerFollowing(type: PROFILEMODE.FOLLOWING, userID: (self.viewModel?.userID!)!)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PPFollowerFollowingViewControllerID") as! PPFollowerFollowingViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                cell.onFollowerClicked = {
//                    SwinjectStoryboard.defaultContainer.assembleFollowerFollowing(type: PROFILEMODE.FOLLOWER, userID:  (self.viewModel?.userID!)!)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PPFollowerFollowingViewControllerID") as! PPFollowerFollowingViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                cell.onFavoriteClicked = {
//                    SwinjectStoryboard.defaultContainer.assembleFavoritePost(userID: (self.viewModel?.userID!)!)
//                    let sb = SwinjectStoryboard.create(name: "Profile",
//                                                       bundle: nil,
//                                                       container: SwinjectStoryboard.defaultContainer)
//                    let nextVC = sb.instantiateViewController(withIdentifier: "PCFavoritesViewControllerID") as! PCFavoritesViewController
//                    self.navigationController?.pushViewController(nextVC, animated: true)
//                }
//                return cell
//            }
//
//        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "PPNormalVerticalCollectionViewItemTableViewCellID") as! PPNormalVerticalCollectionViewItemTableViewCell
        cell.bind(items: (self.viewModel?.postItems.value)!, viewModel: self.viewModel!)
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
