//
//  LikesVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import UIKit
import RxCocoa
import RxSwift
import Async
import PixelPhotoSDK

class LikesVC: BaseVC {
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    private var postLikeArray = [GetLikesModel.Datum]()
    private var refreshControl = UIRefreshControl()
    
    var disposeBag = DisposeBag()
    var viewModel : LikesViewModeling?
    var alreadyInitialize = false
    var contentIndexPath : IndexPath?
    var postId:Int? = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        setupUI()
        self.fetchLikes()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    func setupUI(){
        
        self.title = "Likes"
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        
        self.contentTblView.register(UINib(nibName: "PPProfileCheckBoxItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPProfileCheckBoxItemTableViewCellID")
    }
    
    @objc func refresh(sender:AnyObject) {
        self.postLikeArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchLikes()
        refreshControl.endRefreshing()
    }
    private func fetchLikes(){
        if Connectivity.isConnectedToNetwork(){
            self.postLikeArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postID = postId ?? 0
            Async.background({
                LikeManager.instance.getLike(accessToken: accessToken, postId: postID, limit: 10, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.postLikeArray = success?.data ?? []
                                if self.postLikeArray.isEmpty{
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

extension LikesVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.postLikeArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPProfileCheckBoxItemTableViewCellID") as! PPProfileCheckBoxItemTableViewCell
        let object = postLikeArray[indexPath.row]
        cell.vcLikes = self
        cell.userId = object.userID ?? 0
        cell.profileNameLbl.text = object.username ?? ""
        cell.userNameLbl.text = "Last seen \(object.timeText ?? "")"
        let url = URL.init(string:object.avatar ?? "")
        cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        if object.userID == AppInstance.instance.userId ?? 0{
            cell.followBtn.isHidden = true
            cell.checkBox.isHidden = true
        }else{
            cell.followBtn.isHidden = false
            cell.checkBox.isHidden = true

        }
        if object.isFollowing == 1{
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

