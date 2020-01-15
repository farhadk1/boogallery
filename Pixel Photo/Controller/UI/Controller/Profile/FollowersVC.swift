//
//  FollowersVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import UIKit
import Async
import PixelPhotoSDK

class FollowersVC: BaseVC {
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var followersArray = [FollowFollowingModel.Datum]()
    private var refreshControl = UIRefreshControl()
    var userid:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchFollowers()
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
        
        self.title = "Followers"
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        
        self.contentTblView.separatorStyle = .none
        self.contentTblView.register(R.nib.ppProfileCheckBoxItemTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.ppProfileCheckBoxItemTableViewCellID.identifier)
        
        
        
    }
    @objc func refresh(sender:AnyObject) {
        self.followersArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchFollowers()
        refreshControl.endRefreshing()
        
    }
    
    private func fetchFollowers(){
        if Connectivity.isConnectedToNetwork(){
            self.followersArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = userid ?? 0
            Async.background({
                FollowFollowingManager.instance.fetchFollowers(userId: userId, accessToken: accessToken, limit: 10, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.followersArray = success?.data ?? []
                                if self.followersArray.isEmpty{
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
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
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

extension FollowersVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.followersArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.ppProfileCheckBoxItemTableViewCellID.identifier) as! PPProfileCheckBoxItemTableViewCell
        let object = followersArray[indexPath.row]
        cell.vcFollowers = self
        cell.userId = object.userID ?? 0
        cell.profileNameLbl.text = object.username ?? ""
        cell.userNameLbl.text = "Last seen \(object.timeText ?? "")"
        let url = URL.init(string:object.avatar ?? "")
        cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        if object.isFollowing!{
            cell.followBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
            cell.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            cell.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
            
        }else{
            cell.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
            cell.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
            cell.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.post.showUserProfileVC()
        let object = followersArray[indexPath.row]
        let objectToSend = ShowUserProfileData(fname: object.fname, lname: object.lname, username: object.username, aboutMe: object.about, followersCount: object.followers, followingCount: object.following, postCount: object.posts, isFollowing: object.isFollowing, userId: object.userID,imageString: object.avatar,timeText: object.timeText,isAdmin: object.admin)
        vc!.object = objectToSend
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
