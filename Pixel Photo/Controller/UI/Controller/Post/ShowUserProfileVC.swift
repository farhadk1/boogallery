//
//  ShowUserProfileVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 05/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import DropDown
import PixelPhotoSDK

class ShowUserProfileVC: BaseVC {
    @IBOutlet weak var moreBtn: UIBarButtonItem!
    
    @IBOutlet weak var followingViewLabel: UILabel!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var messageView: UIView!
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
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    var object:ShowUserProfileData?
    private var userDataArray : FetchPostModel.DataClass?
    private let moreDropdown = DropDown()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchUserPostByUserId()
        self.customizeDropdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false

    }
    @IBAction func morePressed(_ sender: Any) {
        self.moreDropdown.show()
    }
    private func setupUI(){
        self.usernameLabel.text = object?.username ?? ""
        self.fillNameLabel.text = "\(object?.fname  ?? "") \(object?.lname  ?? "")"
        
        self.followersCountLabel.text = "\(object?.followersCount  ?? 0)"
        self.followingsCountLabel.text = "\(object?.followingCount  ?? 0)"
        self.favoriteCountLabel.text = "\(object?.postCount  ?? 0)"
        
        let url = URL.init(string:object?.imageString  ?? "")
        self.profileImage.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        
        if object!.isFollowing!{
            self.followingViewLabel.textColor = .black
            self.followView.backgroundColor = UIColor.hexStringToUIColor(hex: "9A9A9A")
        }else{
            self.followView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
            self.followingViewLabel.textColor = .white
        }
         self.messageView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
        
        self.contentCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicVideoItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicImageItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicImageItemCollectionViewCellID")
        
        let followViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followViewTapped(tapGestureRecognizer:)))
        followView.isUserInteractionEnabled = true
        followView.addGestureRecognizer(followViewTapGestureRecognizer)
        
        let messageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(messageViewTapped(tapGestureRecognizer:)))
        messageView.isUserInteractionEnabled = true
        messageView.addGestureRecognizer(messageViewTapGestureRecognizer)
        
        let followersTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followersTapped(tapGestureRecognizer:)))
        followersStack.isUserInteractionEnabled = true
        followersStack.addGestureRecognizer(followersTapGestureRecognizer)
        
        let followingTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followingTapped(tapGestureRecognizer:)))
        followingStack.isUserInteractionEnabled = true
        followingStack.addGestureRecognizer(followingTapGestureRecognizer)
        
        
    }
    
    @objc func messageViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        let vc = R.storyboard.chat.chatVC()
        vc?.userID = object?.userId ?? 0
        vc?.username = object?.username ?? ""
        vc?.lastSeen = object?.timeText ?? ""
        vc?.isAdmin = object?.isAdmin ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @objc func followViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.followUnFollow()
    }
    @objc func followersTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let vc = R.storyboard.profile.followersVC()
        vc?.userid = object?.userId ?? 0

        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func followingTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let vc = R.storyboard.profile.followingVC()
        vc?.userid = object?.userId ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func customizeDropdown(){
        moreDropdown.dataSource = ["Block"]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        //        moreDropdown.bottomOffset = CGPoint(x: 312, y:-270)
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.blockUser()
            
            print("Index = \(index)")
        }
    }
    private func fetchUserPostByUserId(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = object?.userId ?? 0
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
    private func blockUser(){
        if self.object?.isAdmin == 1{
            let alert = UIAlertController(title: "", message: "You cannot block this user because it is administrator", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion:nil)
        }else{
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = self.object?.userId ?? 0
            Async.background({
                BlockUsersManager.instance.blockUnBlockUsers(accessToken: accessToken, userId: userId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.message ?? "")")
                                self.view.makeToast("User has been blocked!!")
                                self.navigationController?.popViewController(animated: true)
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.errors?.errorText)
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription)
                                log.error("error = \(error?.localizedDescription)")
                            }
                        })
                    }
                })
            })
        }
    }
    
    private func followUnFollow(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userID = object?.userId ?? 0
            
            Async.background({
                
                FollowUnFollowManager.instance.followUnFollow(accessToken: accessToken, userId: userID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success?.type!)")
                            if success?.type ?? 0 == 1{
                               
                                    self.followingViewLabel.textColor = .black
                                    self.followView.backgroundColor = UIColor.hexStringToUIColor(hex: "9A9A9A")
                               
                            }else{
                                self.followView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
                                self.followingViewLabel.textColor = .white
                            }
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        })
                    }
                })
            })
        
    }
}
extension ShowUserProfileVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    
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
            
           let vc = R.storyboard.post.showPostVC()
            let objectToSend = ShowUserProfileData(fname: userItem?.fname, lname: userItem?.lname, username: userItem?.username, aboutMe: userItem?.about, followersCount: userItem?.followers, followingCount: userItem?.following, postCount: userItem?.posts, isFollowing: self.userDataArray?.isFollowing, userId: userItem?.userID,imageString: userItem?.avatar,timeText: userItem?.timeText,isAdmin: userItem?.admin)
            let object = ShowPostModel(userId: item?.userID, imageString: item?.avatar, username: item?.username, type: item?.type, timeText: item?.timeText, MediaURL: item?.mediaSet![0].file, likesCount: item?.likes, commentCount: item?.comments?.count, isLiked: item?.isLiked, isSaved: item?.isSaved, showUserProfile: objectToSend,mediaCount:item?.mediaSet?.count,postId: item?.postID,description: item?.userPostDescription,youtube: item?.youtube,MediaUrlsArray: mediaSet)
            vc!.object = object
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    
}
