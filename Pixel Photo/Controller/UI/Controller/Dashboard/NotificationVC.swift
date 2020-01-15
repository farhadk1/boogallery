//
//  NotificationVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 30/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class NotificationVC: BaseVC {
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var notificationsArray = [NotificationModel.Datum]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchNotifications()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func setupUI(){
        
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        
        self.contentTblView.separatorStyle = .none
        self.contentTblView.register(R.nib.ppNotificationItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppNotificationItemTableViewCellID.identifier)
        
        
    }
    @objc func refresh(sender:AnyObject) {
        self.notificationsArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchNotifications()
        refreshControl.endRefreshing()
        
    }
    
    private func fetchNotifications(){
        if Connectivity.isConnectedToNetwork(){
            self.notificationsArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                NotificationManager.instance.getNotification(accessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.notificationsArray = success?.data ?? []
                                if self.notificationsArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.contentTblView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.contentTblView.reloadData()
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

extension NotificationVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.notificationsArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ppNotificationItemTableViewCellID.identifier) as! PPNotificationItemTableViewCell
        let object = notificationsArray[indexPath.row]
        
        if object.type == "followed_u" {
            cell.statusLbl.text = NSLocalizedString("followed you", comment: "")
        }else if object.type == "liked_ur_post" {
            cell.statusLbl.text = NSLocalizedString("liked your post", comment: "")
        }else if object.type == "commented_ur_post" {
            cell.statusLbl.text = NSLocalizedString("commented on your post", comment: "")
        }else if object.type == "mentioned_u_in_comment" {
            cell.statusLbl.text = NSLocalizedString("mentioned you in a comment", comment: "")
        }else if object.type == "mentioned_u_in_post" {
            cell.statusLbl.text = NSLocalizedString("mentioned you in a post", comment: "")
        }
        let url = URL.init(string:object.avatar ?? "")
        cell.profileNameLbl.text = object.username ?? ""

        cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let object = notificationsArray[indexPath.row]

        if object.type == "followed_u" {
            let vc = R.storyboard.post.showUserProfileVC()
            let objectToSend = ShowUserProfileData(fname: object.userData?.fname, lname: object.userData?.lname, username: object.userData?.username, aboutMe: object.userData?.about, followersCount: object.userData?.followers, followingCount: object.userData?.following, postCount: object.userData?.posts, isFollowing: object.userData?.isFollowing, userId: object.userData?.userID,imageString: object.userData?.avatar,timeText: object.userData?.timeText,isAdmin: object.userData?.admin)
            vc!.object = objectToSend
            self.navigationController?.pushViewController(vc!, animated: true)
        }else {
            let item = notificationsArray[indexPath.row].postData
            let userItem =  notificationsArray[indexPath.row].userData
            var mediaSet = [String]()
            if (item?.mediaSet!.count) ?? 0 > 1{
                item?.mediaSet?.forEach({ (it) in
                    mediaSet.append(it.file ?? "")
                })
            }
            log.verbose("MediaSet = \(mediaSet)")
            let vc = R.storyboard.post.showPostVC()
            let objectToSend = ShowUserProfileData(fname: userItem?.fname, lname: userItem?.lname, username: userItem?.username, aboutMe: userItem?.about, followersCount: userItem?.followers, followingCount: userItem?.following, postCount: userItem?.posts, isFollowing: userItem?.isFollowing, userId: userItem?.userID,imageString: userItem?.avatar,timeText: userItem?.timeText,isAdmin: userItem?.admin)
            let object = ShowPostModel(userId: item?.userID, imageString: item?.avatar, username: item?.username, type: item?.type, timeText: item?.timeText, MediaURL: item?.mediaSet![0].file, likesCount: item?.likes, commentCount: item?.comments?.count ?? 0, isLiked: item?.isLiked, isSaved: item?.isSaved, showUserProfile: objectToSend,mediaCount:item?.mediaSet?.count,postId: item?.postID,description: item?.postDataDescription,youtube: item?.youtube,MediaUrlsArray:mediaSet)
            vc!.object = object
            
            self.navigationController?.pushViewController(vc!, animated: true)

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
}
