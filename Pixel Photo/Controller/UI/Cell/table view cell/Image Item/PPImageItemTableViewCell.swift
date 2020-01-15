//
//  PPPostItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SDWebImage
import RxGesture
import ActionSheetPicker_3_0
import PixelPhotoFramework
import ActiveLabel
import Async
import PixelPhotoSDK


class PPImageItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentImgView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var numLikeLbl: UILabel!
    @IBOutlet weak var numCommentLbl: UILabel!
    @IBOutlet weak var typeImgView: UIImageView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var captionLbl: ActiveLabel!
    
    @IBOutlet weak var allCommentViewTopContraints: NSLayoutConstraint!
    @IBOutlet weak var showCallCommentsTopConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var topView: UIView!
    private var aspectConstraint: NSLayoutConstraint?
    
    var disposeBag = DisposeBag()
    
    fileprivate var viewModel : HomeViewModeling?
    fileprivate var viewModelPostItem : PostItemViewModeling?
    
    var itemObs : BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    
    @IBOutlet weak var showAllCommentLbl: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var addCommentBtn: UIButton!
    @IBOutlet weak var likedBtn: UIButton!
    
    var loaded = false
    var showPostModel:ShowPostModel?
    var vc:ShowPostVC?
    var homePostModel:HomePostModel.Datum?
    var homeVC:HomeVC?
    var hashTagVC:FetchHashTagPostVC?
    var hastagModel:PostByHashTagModel.Datum?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.topView.backgroundColor = UIColor.white
        self.showAllCommentLbl.text = NSLocalizedString("Show all comment", comment: "")
        self.profileImageView.isCircular(borderColor: UIColor.clear)
        
        self.captionLbl.numberOfLines = 0
        self.captionLbl.enabledTypes = [.mention, .hashtag]
        self.captionLbl.customColor[.mention] = UIColor.red
        self.captionLbl.customSelectedColor[.hashtag] = UIColor.blue
        
        let favoiriteTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numLikesTapped(tapGestureRecognizer:)))
        numLikeLbl.isUserInteractionEnabled = true
        numLikeLbl.addGestureRecognizer(favoiriteTapGestureRecognizer)
        
        let numCommentsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numCommentsTapped(tapGestureRecognizer:)))
        numCommentLbl.isUserInteractionEnabled = true
        numCommentLbl.addGestureRecognizer(numCommentsTapGestureRecognizer)
        
        let showAllCommentTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAllCommentsTapped(tapGestureRecognizer:)))
        showAllCommentLbl.isUserInteractionEnabled = true
        showAllCommentLbl.addGestureRecognizer(showAllCommentTapGestureRecognizer)
    }
    @objc func showAllCommentsTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if self.vc != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = showPostModel?.postId ?? 0
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        }else if  self.homeVC != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = homePostModel?.postID ?? 0
            self.homeVC?.navigationController?.pushViewController(vc!, animated: true)
        } else if  self.hashTagVC != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = hastagModel?.postID ?? 0
            self.hashTagVC?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    @objc func numCommentsTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if self.vc != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = showPostModel?.postId ?? 0
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        }else if  self.homeVC != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = homePostModel?.postID ?? 0
            self.homeVC?.navigationController?.pushViewController(vc!, animated: true)
        }else if  self.hashTagVC != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = hastagModel?.postID ?? 0
            self.hashTagVC?.navigationController?.pushViewController(vc!, animated: true)
        }
        
        
    }
    @objc func numLikesTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        if self.vc != nil{
            let vc = R.storyboard.post.likesVC()
            vc?.postId = showPostModel?.postId ?? 0
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        }else if  self.homeVC != nil{
            let vc = R.storyboard.post.likesVC()
            vc?.postId = homePostModel?.postID ?? 0
            self.homeVC?.navigationController?.pushViewController(vc!, animated: true)
        }else if  self.hashTagVC != nil{
            
            let vc = R.storyboard.post.likesVC()
            vc?.postId = hastagModel?.postID ?? 0
            self.hashTagVC?.navigationController?.pushViewController(vc!, animated: true)
            
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("PPImageItemTableViewCell prepareForReuse")
        
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.vc != nil{
            if showPostModel?.description == "" {
                self.captionLbl.isHidden = true
                self.allCommentViewTopContraints.isActive = true
                self.showCallCommentsTopConstraints.isActive = false
            }else{
                self.captionLbl.isHidden = false
                self.allCommentViewTopContraints.isActive = false
                self.showCallCommentsTopConstraints.isActive = true
                self.captionLbl.text = self.showPostModel?.description!.decodeHtmlEntities()?.arrangeMentionedContacts()
            }
        }else if self.homeVC != nil{
            if homePostModel?.datumDescription == "" {
                self.captionLbl.isHidden = true
                self.allCommentViewTopContraints.isActive = true
                self.showCallCommentsTopConstraints.isActive = false
            }else{
                self.captionLbl.isHidden = false
                self.allCommentViewTopContraints.isActive = false
                self.showCallCommentsTopConstraints.isActive = true
                self.captionLbl.text = self.homePostModel?.datumDescription!.decodeHtmlEntities()?.arrangeMentionedContacts()
            }
        }else if self.hashTagVC != nil{
            if hastagModel?.datumDescription == "" {
                self.captionLbl.isHidden = true
                self.allCommentViewTopContraints.isActive = true
                self.showCallCommentsTopConstraints.isActive = false
            }else{
                self.captionLbl.isHidden = false
                self.allCommentViewTopContraints.isActive = false
                self.showCallCommentsTopConstraints.isActive = true
                self.captionLbl.text = self.hastagModel?.datumDescription!.decodeHtmlEntities()?.arrangeMentionedContacts()
            }
        }
    }
    @IBAction func morePressed(_ sender: Any) {
        if self.vc != nil{
            showActionPicker2()
            
        }else{
            showActionPicker()
        }
    }
    @IBAction func sharePressed(_ sender: Any) {
        self.sharePost()
    }
    @IBAction func favoritePressed(_ sender: Any) {
        
        self.favoriteUnFavorite()
    }
    @IBAction func commentPressed(_ sender: Any) {
        if self.vc != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = showPostModel?.postId ?? 0
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        }else if self.homeVC != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = homePostModel?.postID ?? 0
            self.homeVC?.navigationController?.pushViewController(vc!, animated: true)
        }else if self.hashTagVC != nil{
            let vc = R.storyboard.post.commentVC()
            vc?.postId = hastagModel?.postID ?? 0
            self.hashTagVC?.navigationController?.pushViewController(vc!, animated: true)
        }
       
    }
    @IBAction func likePressed(_ sender: Any) {
        likeDisLike()
    }
    private func deletePost(){
        if self.vc != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = showPostModel?.postId ?? 0
            
            Async.background({
                DeletePostManager.instance.deletePost(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.vc?.navigationController?.popViewController(animated: true)
                            
                            log.verbose("Success = \(success!)")
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if self.homeVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = homePostModel?.postID ?? 0
            
            Async.background({
                DeletePostManager.instance.deletePost(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.homeVC?.navigationController?.popViewController(animated: true)
                            
                            log.verbose("Success = \(success!)")
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if self.hashTagVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = hastagModel?.postID ?? 0
            
            Async.background({
                DeletePostManager.instance.deletePost(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.hashTagVC?.navigationController?.popViewController(animated: true)
                            
                            log.verbose("Success = \(success!)")
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }
        
    }
    
    private func reportPost(){
        if  self.vc != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = self.showPostModel?.postId ?? 0
            
            Async.background({
                ReportManager.instance.reportPost(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            self.vc?.navigationController?.popViewController(animated: true)
                            
                            
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if self.homeVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = homePostModel?.postID ?? 0
            
            Async.background({
                ReportManager.instance.reportPost(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            self.homeVC?.navigationController?.popViewController(animated: true)
                            
                            
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if self.hashTagVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = hastagModel?.postID ?? 0
            
            Async.background({
                ReportManager.instance.reportPost(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            self.hashTagVC?.navigationController?.popViewController(animated: true)
                            
                            
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }
        
    }
    
    private func likeDisLike(){
        if self.vc != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = showPostModel?.postId ?? 0
            
            Async.background({
                
                LikeManager.instance.addAndRemoveLike(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            if success?.isLiked ?? 0 == 1 {
                                self.likedBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
                            }else{
                                self.likedBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if self.homeVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = homePostModel?.postID ?? 0
            
            Async.background({
                
                LikeManager.instance.addAndRemoveLike(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            if success?.isLiked ?? 0 == 1 {
                                self.likedBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
                            }else{
                                self.likedBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if self.hashTagVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = hastagModel?.postID ?? 0
            
            Async.background({
                
                LikeManager.instance.addAndRemoveLike(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            if success?.isLiked ?? 0 == 1 {
                                self.likedBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
                            }else{
                                self.likedBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }
        
    }
    private func favoriteUnFavorite(){
        if vc != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = showPostModel?.postId ?? 0
            
            Async.background({
                FavoriteManager.instance.addAndRemoveFavorite(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            if success?.type ?? 0 == 1 {
                                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_active"), for: UIControl.State.normal)
                            }else{
                                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_inactive"), for: UIControl.State.normal)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if homeVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = homePostModel?.postID ?? 0
            
            Async.background({
                FavoriteManager.instance.addAndRemoveFavorite(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            if success?.type ?? 0 == 1 {
                                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_active"), for: UIControl.State.normal)
                            }else{
                                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_inactive"), for: UIControl.State.normal)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else if hashTagVC != nil{
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postId = hastagModel?.postID ?? 0
            
            Async.background({
                FavoriteManager.instance.addAndRemoveFavorite(accessToken: accessToken, postId: postId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("Success = \(success!)")
                            
                            if success?.type ?? 0 == 1 {
                                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_active"), for: UIControl.State.normal)
                            }else{
                                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_inactive"), for: UIControl.State.normal)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }
        
        
    }
    private func sharePost(){
        if self.vc != nil{
            let myWebsite = NSURL(string:showPostModel?.MediaURL ?? "")
            let shareAll = [myWebsite] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.vc!.view
            self.vc!.present(activityViewController, animated: true, completion: nil)
        }else if self.homeVC != nil{
            let myWebsite = NSURL(string:homePostModel?.mediaSet![0].file ?? "")
            let shareAll = [myWebsite] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.homeVC!.view
            self.homeVC!.present(activityViewController, animated: true, completion: nil)
        }else if self.hashTagVC != nil{
            let myWebsite = NSURL(string:hastagModel?.mediaSet![0].file ?? "")
            let shareAll = [myWebsite] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.hashTagVC!.view
            self.hashTagVC!.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    func showActionPicker(){
        if showPostModel?.showUserProfile?.userId == AppInstance.instance.userId{
            ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                         rows: [NSLocalizedString("Go To Post", comment: ""),
                                                NSLocalizedString("Report This Post", comment: ""),
                                                NSLocalizedString("Copy", comment: ""),
                                                NSLocalizedString("Delete This Post", comment: "")],
                                         initialSelection: 0,
                                         doneBlock: { (picker, value, index) in
                                            
                                            if value == 0 {
                                                self.viewModel?.showPost.accept(self.itemObs)
                                            }else if value == 1 {
                                                self.reportPost()
                                            }else if value == 2  {
                                                if self.vc != nil {
                                                    UIPasteboard.general.string = self.showPostModel?.MediaURL
                                                }else if self.homeVC != nil{
                                                    UIPasteboard.general.string = self.homePostModel?.mediaSet![0].file
                                                }else if self.hashTagVC != nil{
                                                    UIPasteboard.general.string = self.hastagModel?.mediaSet![0].file
                                                }
                                            }else{
                                                self.deletePost()
                                            }
                                            
                                            return
                                            
            }, cancel:  { ActionStringCancelBlock in return }, origin: self)
        }else{
            ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                         rows: [NSLocalizedString("Go To Post", comment: ""),
                                                NSLocalizedString("Report This Post", comment: ""),
                                                NSLocalizedString("Copy", comment: "")],
                                         initialSelection: 0,
                                         doneBlock: { (picker, value, index) in
                                            
                                            if value == 0 {
                                                if self.homeVC != nil{
                                                    let item = self.homePostModel
                                                    let userItem = self.homePostModel?.userData
                                                    var mediaSet = [String]()
                                                    if (item?.mediaSet!.count)! > 1{
                                                        item?.mediaSet?.forEach({ (it) in
                                                            mediaSet.append(it.file ?? "")
                                                        })
                                                    }
                                                    log.verbose("MediaSet = \(mediaSet)")
                                                    let vc = R.storyboard.post.showPostVC()
                                                    let objectToSend = ShowUserProfileData(fname: userItem?.fname, lname: userItem?.lname, username: userItem?.username, aboutMe: userItem?.about, followersCount: 0, followingCount: 0, postCount: userItem?.posts, isFollowing: userItem?.following, userId: userItem?.userID,imageString: userItem?.avatar,timeText: item?.timeText,isAdmin: userItem?.admin)
                                                    let object = ShowPostModel(userId: item?.userID, imageString: item?.avatar, username: item?.username, type: item?.type, timeText: item?.timeText, MediaURL: item?.mediaSet![0].file, likesCount: item?.likes, commentCount: item?.comments?.count, isLiked: item?.isLiked, isSaved: item?.isSaved, showUserProfile: objectToSend,mediaCount:item?.mediaSet?.count,postId: item?.postID,description: item?.datumDescription,youtube: item?.youtube,MediaUrlsArray:mediaSet)
                                                    vc!.object = object
                                                    
                                                    self.homeVC?.navigationController?.pushViewController(vc!, animated: true)
                                                }else if self.hashTagVC != nil{
                                                    let item = self.hastagModel
                                                    let userItem = self.hastagModel?.userData
                                                    var mediaSet = [String]()
                                                    if (item?.mediaSet!.count)! > 1{
                                                        item?.mediaSet?.forEach({ (it) in
                                                            mediaSet.append(it.file ?? "")
                                                        })
                                                    }
                                                    log.verbose("MediaSet = \(mediaSet)")
                                                    let vc = R.storyboard.post.showPostVC()
                                                    let objectToSend = ShowUserProfileData(fname: userItem?.fname, lname: userItem?.lname, username: userItem?.username, aboutMe: userItem?.about, followersCount: 0, followingCount: 0, postCount: userItem?.posts, isFollowing: userItem?.following, userId: userItem?.userID,imageString: userItem?.avatar,timeText: item?.timeText,isAdmin: userItem?.admin)
                                                    let object = ShowPostModel(userId: item?.userID, imageString: item?.avatar, username: item?.username, type: item?.type, timeText: item?.timeText, MediaURL: item?.mediaSet![0].file, likesCount: item?.likes, commentCount: item?.comments?.count, isLiked: item?.isLiked, isSaved: item?.isSaved, showUserProfile: objectToSend,mediaCount:item?.mediaSet?.count,postId: item?.postID,description: item?.datumDescription,youtube: item?.youtube,MediaUrlsArray:mediaSet)
                                                    vc!.object = object
                                                    
                                                    self.hashTagVC?.navigationController?.pushViewController(vc!, animated: true)
                                                }
                                            }else if value == 1 {
                                                self.reportPost()
                                            }else {
                                                if self.vc != nil {
                                                    UIPasteboard.general.string = self.showPostModel?.MediaURL
                                                }else if self.homeVC != nil{
                                                    UIPasteboard.general.string = self.homePostModel?.mediaSet![0].file
                                                }else if self.hashTagVC != nil{
                                                    UIPasteboard.general.string = self.hastagModel?.mediaSet![0].file
                                                }
                                            }
                                            
                                            return
                                            
            }, cancel:  { ActionStringCancelBlock in return }, origin: self)
        }
    }
    
    func showActionPicker2(){
        if self.vc != nil{
            if showPostModel?.showUserProfile?.userId == AppInstance.instance.userId ?? 0 {
                ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                             rows: [NSLocalizedString("Report This Post", comment: ""),
                                                    NSLocalizedString("Copy", comment: ""),
                                                    NSLocalizedString("Delete This Post", comment: "")],
                                             initialSelection: 0,
                                             doneBlock: { (picker, value, index) in
                                                print(value)
                                                if value == 0 {
                                                    self.reportPost()
                                                }else if value == 1 {
                                                    
                                                    UIPasteboard.general.string = self.showPostModel?.MediaURL
                                                    
                                                    
                                                }else if value == 2 {
                                                    self.deletePost()
                                                }
                                                return
                                                
                }, cancel:  { ActionStringCancelBlock in return }, origin: self)
            }else{
                ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                             rows: [NSLocalizedString("Report This Post", comment: ""),
                                                    NSLocalizedString("Copy", comment: "")],
                                             initialSelection: 0,
                                             doneBlock: { (picker, value, index) in
                                                print(value)
                                                
                                                if value == 0 {
                                                    self.reportPost()
                                                    
                                                }else if value == 1 {
                                                    
                                                    UIPasteboard.general.string = self.showPostModel?.MediaURL
                                                    
                                                    
                                                }
                                                
                                                return
                                                
                }, cancel:  { ActionStringCancelBlock in return }, origin: self)
            }
        }else if self.homeVC != nil{
            if homePostModel?.userID  == AppInstance.instance.userId ?? 0 {
                ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                             rows: [NSLocalizedString("Report This Post", comment: ""),
                                                    NSLocalizedString("Copy", comment: ""),
                                                    NSLocalizedString("Delete This Post", comment: "")],
                                             initialSelection: 0,
                                             doneBlock: { (picker, value, index) in
                                                print(value)
                                                if value == 0 {
                                                    self.reportPost()
                                                }else if value == 1 {
                                                    
                                                    UIPasteboard.general.string = self.homePostModel?.mediaSet![0].file ?? ""
                                                    
                                                    
                                                }else if value == 2 {
                                                    self.deletePost()
                                                }
                                                return
                                                
                }, cancel:  { ActionStringCancelBlock in return }, origin: self)
            }else{
                ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                             rows: [NSLocalizedString("Report This Post", comment: ""),
                                                    NSLocalizedString("Copy", comment: "")],
                                             initialSelection: 0,
                                             doneBlock: { (picker, value, index) in
                                                print(value)
                                                
                                                if value == 0 {
                                                    self.reportPost()
                                                    
                                                }else if value == 1 {
                                                    UIPasteboard.general.string = self.homePostModel?.mediaSet![0].file ?? ""
                                                }
                                                
                                                return
                                                
                }, cancel:  { ActionStringCancelBlock in return }, origin: self)
            }
        }else if self.hashTagVC != nil{
            if hastagModel?.userID  == AppInstance.instance.userId ?? 0 {
                ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                             rows: [NSLocalizedString("Report This Post", comment: ""),
                                                    NSLocalizedString("Copy", comment: ""),
                                                    NSLocalizedString("Delete This Post", comment: "")],
                                             initialSelection: 0,
                                             doneBlock: { (picker, value, index) in
                                                print(value)
                                                if value == 0 {
                                                    self.reportPost()
                                                }else if value == 1 {
                                                    
                                                    UIPasteboard.general.string = self.hastagModel?.mediaSet![0].file ?? ""
                                                    
                                                    
                                                }else if value == 2 {
                                                    self.deletePost()
                                                }
                                                return
                                                
                }, cancel:  { ActionStringCancelBlock in return }, origin: self)
            }else{
                ActionSheetStringPicker.show(withTitle: NSLocalizedString("Post", comment: ""),
                                             rows: [NSLocalizedString("Report This Post", comment: ""),
                                                    NSLocalizedString("Copy", comment: "")],
                                             initialSelection: 0,
                                             doneBlock: { (picker, value, index) in
                                                print(value)
                                                
                                                if value == 0 {
                                                    self.reportPost()
                                                    
                                                }else if value == 1 {
                                                    UIPasteboard.general.string = self.hastagModel?.mediaSet![0].file ?? ""
                                                }
                                                
                                                return
                                                
                }, cancel:  { ActionStringCancelBlock in return }, origin: self)
            }
        }
        
    }
    
   
    func bind(item : ShowPostModel,viewModel:PostItemViewModeling?){
        
            self.topView.backgroundColor = UIColor.white
            self.contentImgView.image = nil
            showPostModel = item
            
            
            self.timeLbl.text = item.timeText ?? ""
            self.profileNameLbl.text = item.username ?? ""
            
            self.captionLbl.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            self.captionLbl.handleMentionTap { mention in
                print("Success. You just tapped the \(mention) mentioned")
            }
            
            self.typeImgView.image = UIImage(named: "ic_type_video")
            
            if item.isLiked! {
                self.likedBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
            }else{
                self.likedBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
            }
            
            if item.isSaved! {
                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_active"), for: UIControl.State.normal)
            }else{
                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_inactive"), for: UIControl.State.normal)
            }
            
            if item.likesCount! > 1 {
                self.numLikeLbl.text = "\(item.likesCount!) Likes"
            }else{
                self.numLikeLbl.text = "\(item.likesCount!) Like"
            }
            
            if item.commentCount! > 1 {
                self.numCommentLbl.text = "\(item.commentCount!) Comments"
            }else{
                self.numCommentLbl.text = "\(item.commentCount!) Comment"
            }
            self.topView.backgroundColor = UIColor.white
            
            if let profImg = SDImageCache.shared.imageFromCache(forKey:item.imageString!) {
                self.profileImageView.image = profImg
            }else{
                self.profileImageView.sd_setImage(with: URL(string:item.imageString!),
                                                  placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.profileImageView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.imageString!, completion: {
                                                            self.profileImageView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        
        
    self.loadThumbNail(item: item.MediaURL ?? "")

        
    }
    func homeBinding(item : HomePostModel.Datum,viewModel:PostItemViewModeling?,index:Int){
        
        if loaded == false {
            homePostModel = item
            
            self.timeLbl.text = item.timeText ?? ""
            self.profileNameLbl.text = item.username ?? ""
            
            self.captionLbl.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            self.captionLbl.handleMentionTap { mention in
                print("Success. You just tapped the \(mention) mentioned")
            }
            
            self.typeImgView.image = UIImage(named: "ic_type_image")
            
            if item.isLiked! {
                self.likedBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
            }else{
                self.likedBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
            }
            
            if item.isSaved! {
                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_active"), for: UIControl.State.normal)
            }else{
                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_inactive"), for: UIControl.State.normal)
            }
            
            if item.likes! > 1 {
                self.numLikeLbl.text = "\(item.likes!) Likes"
            }else{
                self.numLikeLbl.text = "\(item.likes!) Like"
            }
            
            if (item.comments?.count)! > 1 {
                self.numCommentLbl.text = "\(item.comments?.count ?? 0) Comments"
            }else{
                self.numCommentLbl.text = "\(item.comments?.count ?? 0) Comment"
            }
            self.topView.backgroundColor = UIColor.white
            
            
            if let profImg = SDImageCache.shared.imageFromCache(forKey:item.avatar!) {
                self.profileImageView.image = profImg
            }else{
                self.profileImageView.sd_setImage(with: URL(string:item.avatar!),
                                                  placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.profileImageView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.avatar!, completion: {
                                                            self.profileImageView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }
       
        self.loadThumbNail(item: item.mediaSet![0].file ?? "")

        
    }
    func hashTagBinding(item : PostByHashTagModel.Datum,viewModel:PostItemViewModeling?,index:Int){
        
        if loaded == false {
            hastagModel = item
            
            self.timeLbl.text = item.timeText ?? ""
            self.profileNameLbl.text = item.username ?? ""
            
            self.captionLbl.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            self.captionLbl.handleMentionTap { mention in
                print("Success. You just tapped the \(mention) mentioned")
            }
            
            self.typeImgView.image = UIImage(named: "ic_type_image")
            
            if item.isLiked! {
                self.likedBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
            }else{
                self.likedBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
            }
            
            if item.isSaved! {
                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_active"), for: UIControl.State.normal)
            }else{
                self.favoriteBtn.setImage(UIImage(named: "ic_favorite_inactive"), for: UIControl.State.normal)
            }
            
            if item.likes! > 1 {
                self.numLikeLbl.text = "\(item.likes!) Likes"
            }else{
                self.numLikeLbl.text = "\(item.likes!) Like"
            }
            
            if (item.comments?.count)! > 1 {
                self.numCommentLbl.text = "\(item.comments?.count ?? 0) Comments"
            }else{
                self.numCommentLbl.text = "\(item.comments?.count ?? 0) Comment"
            }
            self.topView.backgroundColor = UIColor.white
            
            
            if let profImg = SDImageCache.shared.imageFromCache(forKey:item.avatar!) {
                self.profileImageView.image = profImg
            }else{
                self.profileImageView.sd_setImage(with: URL(string:item.avatar!),
                                                  placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.profileImageView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.avatar!, completion: {
                                                            self.profileImageView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }
        
        self.loadThumbNail(item: item.mediaSet![0].file ?? "")
        
        
    }
   

    func loadThumbNail(item:String){
        
        if self.aspectConstraint != nil {
            self.contentImgView.removeConstraint(self.aspectConstraint!)
        }
        
        if item == "" {
            if let image = SDImageCache.shared.imageFromCache(forKey:item) {
                
                let aspectRatio = (image as UIImage).size.height/(image as UIImage).size.width
                
                self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: self.contentImgView,
                                                           attribute: .width,
                                                           multiplier: aspectRatio,
                                                           constant: 0)
                
                self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
                self.contentImgView.addConstraint(self.aspectConstraint!)
                self.contentImgView.image = image
                self.setNeedsLayout()
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                        self.setNeedsLayout()
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item, completion: {
                                                            let aspectRatio = (image! as UIImage).size.height/(image! as UIImage).size.width
                                                            
                                                            self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                                                                       attribute: .height,
                                                                                                       relatedBy: .equal,
                                                                                                       toItem: self.contentImgView,
                                                                                                       attribute: .width,
                                                                                                       multiplier: aspectRatio,
                                                                                                       constant: 0)
                                                            
                                                            self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
                                                            self.contentImgView.addConstraint(self.aspectConstraint!)
                                                            self.contentImgView.image = image
                                                            self.setNeedsLayout()
                                                        })
                                                    }
                }
            }
        }else{
            if let image = SDImageCache.shared.imageFromCache(forKey:item) {
                
                let aspectRatio = (image as UIImage).size.height/(image as UIImage).size.width
                
                self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: self.contentImgView,
                                                           attribute: .width,
                                                           multiplier: aspectRatio,
                                                           constant: 0)
                
                self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
                self.contentImgView.addConstraint(self.aspectConstraint!)
                self.contentImgView.image = image
                self.setNeedsLayout()
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                        self.setNeedsLayout()
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item, completion: {
                                                            let aspectRatio = (image! as UIImage).size.height/(image! as UIImage).size.width
                                                            
                                                            self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                                                                       attribute: .height,
                                                                                                       relatedBy: .equal,
                                                                                                       toItem: self.contentImgView,
                                                                                                       attribute: .width,
                                                                                                       multiplier: aspectRatio,
                                                                                                       constant: 0)
                                                            
                                                            self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
                                                            self.contentImgView.addConstraint(self.aspectConstraint!)
                                                            self.contentImgView.image = image
                                                            self.setNeedsLayout()
                                                        })
                                                    }
                }
            }
        }
        
    }
    
    func loadThumbNailFixHeight(item:HomePostModel.Datum){
        
        self.contentImgView.contentMode = UIView.ContentMode.scaleAspectFill
        self.contentImgView.clipsToBounds = true
        
        if self.aspectConstraint != nil {
            self.contentImgView.removeConstraint(self.aspectConstraint!)
        }
        
        self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                   attribute: .height,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .width,
                                                   multiplier: 1.0,
                                                   constant: 350)
        
        self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
        self.contentImgView.addConstraint(self.aspectConstraint!)
        
        if item.mediaSet![0].extra! == "" {
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].file!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].file!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image!
                                                        })
                                                    }
                                                    
                                                    
                                                    
                                                    
                }
            }
        }else{
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].extra!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].extra!, completion: {
                                                            self.contentImgView.image = image!
                                                        })
                                                    }
                }
            }
        }
        
        
    }
}
