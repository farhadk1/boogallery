//
//  ProfileVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 23/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class ProfileVC: BaseVC {
    
    @IBOutlet weak var fillNameLabel: UILabel!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var favoriteStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var userDataArray : FetchPostModel.DataClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchUserPostByUserId()

    }
    @IBAction func editProfilePressed(_ sender: Any) {
        let vc = R.storyboard.settings.settingsProfileVC()
        vc!.commingFrom = "profile"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func settingPressed(_ sender: Any) {
        let vc = R.storyboard.settings.settingVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func setupUI(){
        self.usernameLabel.text = AppInstance.instance.userProfile?.data?.username ?? ""
        self.fillNameLabel.text = "\(AppInstance.instance.userProfile?.data?.fname ?? "") \(AppInstance.instance.userProfile?.data?.lname ?? "")"
        
        self.followersCountLabel.text = "\(AppInstance.instance.userProfile?.data?.followers ?? 0)"
        self.followingsCountLabel.text = "\(AppInstance.instance.userProfile?.data?.following ?? 0)"
        self.favoriteCountLabel.text = "\(AppInstance.instance.userProfile?.data?.favourites ?? 0)"
        
        let url = URL.init(string:AppInstance.instance.userProfile?.data?.avatar ?? "")
        self.profileImage.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        
        
        self.contentCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicVideoItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicImageItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicImageItemCollectionViewCellID")
        
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        cameraView.isUserInteractionEnabled = true
        cameraView.addGestureRecognizer(profileImageTapGestureRecognizer)
        
        let followersTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followersTapped(tapGestureRecognizer:)))
        followersStack.isUserInteractionEnabled = true
        followersStack.addGestureRecognizer(followersTapGestureRecognizer)
        
        let followingTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followingTapped(tapGestureRecognizer:)))
        followingStack.isUserInteractionEnabled = true
        followingStack.addGestureRecognizer(followingTapGestureRecognizer)
        
        let favoiriteTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favoritesTapped(tapGestureRecognizer:)))
        favoriteStack.isUserInteractionEnabled = true
        favoriteStack.addGestureRecognizer(favoiriteTapGestureRecognizer)
        
        
        
    }
    @objc func favoritesTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let vc = R.storyboard.profile.favoritesVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func followersTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let vc = R.storyboard.profile.followersVC()
        vc?.userid = AppInstance.instance.userId ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func followingTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let vc = R.storyboard.profile.followingVC()
        vc?.userid = AppInstance.instance.userId ?? 0
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
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
    
    private func updateAvatar(imageData:Data){
        
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            
            ProfileManger.instance.updateAvatar(accessToken: accessToken, avatar_data: imageData, completionBlock: { (success, sessionError, error) in
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
                            
                        }                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    })
                }
            })
        })
    }
    private func fetchUserPostByUserId(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background({
                FetchPostManager.instance.fetchPostByUserId(accessToken: accessToken, userId: userid, limit: 10, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? nil)")
                                self.userDataArray = success?.data ?? nil
                                if (self.userDataArray?.userPosts?.isEmpty)!{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.contentCollectionView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.contentCollectionView.reloadData()
                                }
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
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension ProfileVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 , height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userDataArray?.userPosts!.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.userDataArray?.userPosts![indexPath.row]
        
        if item?.type == "video" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID", for: indexPath) as! PPMosaicVideoItemCollectionViewCell
            cell.bindUserPost(item: item!)
            return cell
        }else if item?.type == "image" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
            cell.bindUserPost(item: item!)
            return cell
        }else if item?.type == "gif" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID", for: indexPath) as! PPMosaicGIFItemCollectionViewCell
            
            cell.bindUserPost(item: item!, indexPath: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
        //        cell.bind(item: item)
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.userDataArray?.userPosts![indexPath.row]
        let userItem = self.userDataArray?.userData
        var mediaSet = [String]()
        if (item?.mediaSet!.count)! > 1{
            item?.mediaSet?.forEach({ (it) in
                mediaSet.append(it.file ?? "")
            })
        }
        log.verbose("MediaSet = \(mediaSet)")
        let vc = R.storyboard.post.showPostVC()
        let objectToSend = ShowUserProfileData(fname: userItem?.fname, lname: userItem?.lname, username: userItem?.username, aboutMe: userItem?.about, followersCount: userItem?.followers, followingCount: userItem?.following, postCount: userItem?.posts, isFollowing: self.userDataArray?.isFollowing, userId: userItem?.userID,imageString: userItem?.avatar,timeText: userItem?.timeText,isAdmin: userItem?.admin)
        let object = ShowPostModel(userId: item?.userID, imageString: item?.avatar, username: item?.username, type: item?.type, timeText: item?.timeText, MediaURL: item?.mediaSet![0].file, likesCount: item?.likes, commentCount: item?.comments?.count, isLiked: item?.isLiked, isSaved: item?.isSaved, showUserProfile: objectToSend,mediaCount:item?.mediaSet?.count,postId: item?.postID,description: item?.userPostDescription,youtube: item?.youtube,MediaUrlsArray:mediaSet)
        vc!.object = object
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
extension  ProfileVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.profileImage.image = image
        self.avatarImage  = image ?? nil
        let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
        updateAvatar(imageData: avatarData ??  Data())
        self.dismiss(animated: true, completion: nil)
    }
}
