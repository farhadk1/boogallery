//
//  PPCommentItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import RxCocoa
import SDWebImage
import PixelPhotoSDK
import Async

class PPCommentItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var LikeCommentCountLabel: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var messageTxtView: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var bubbleView: UIView!
    
    var check:String? = ""
    var commentItem:CommentModel.Datum?
     var replyCommentItem:CommentreplyModel.Datum?
    var vc:CommentVC?
    
    //@IBOutlet weak var userNameLbl: UILabel!
    
    var disposeBag = DisposeBag()
    var commentId:Int? = 0
    var likesCount:Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImgView.isCircular()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bubbleView.isRoundedRect(cornerRadius: 10, hasBorderColor: UIColor.clear)
    }
    
    @IBAction func replyPressed(_ sender: Any) {
        let vc = R.storyboard.post.commentReplyVC()!
       vc.profileImageString = self.commentItem?.avatar ?? ""
        vc.username = self.commentItem?.username ?? ""
        vc.commentText = self.commentItem?.text?.decodeHtmlEntities() ?? ""
        vc.timeText = self.commentItem?.timeText ?? ""
       vc.likeCount = self.commentItem?.likes ?? 0
        vc.commentId = self.commentItem?.id ?? 0
        self.vc?.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func likeCommentPressed(_ sender: Any) {
        if replyCommentItem != nil{
            self.likeReplyComment()
        }else{
            self.likeComment()

        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    private func likeComment(){
        let accessToken = AppInstance.instance.accessToken ?? ""
        let commentId = self.commentId ?? 0
        
        Async.background({
            CommentManager.instance.likeComment(accessToken: accessToken, commentId: commentId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.verbose("Success = \(success!)")
                        if success?.type ?? 0 == 1 {
                            self.likeBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
                            self.likesCount = self.likesCount ?? 0 + 1
                            self.LikeCommentCountLabel.text = "like(\(self.likesCount ?? 0 ))"
                        }else{
                            self.likeBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
                            self.likesCount = self.likesCount  ?? 0 - 1
                             self.LikeCommentCountLabel.text = "like(\(self.likesCount ?? 0 ))"
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
    
    private func likeReplyComment(){
        let accessToken = AppInstance.instance.accessToken ?? ""
        let replyid = self.commentId ?? 0
        
        Async.background({
            ReplyCommentManager.instance.likeCommentReply(accessToken: accessToken, replyId: replyid, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.verbose("Success = \(success!)")
                        if success?.type ?? 0 == 1 {
                            self.likeBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
                            self.likesCount = self.likesCount ?? 0 + 1
                            self.LikeCommentCountLabel.text = "like(\(self.likesCount ?? 0 ))"
                        }else{
                            self.likeBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
                            self.likesCount = self.likesCount  ?? 0 - 1
                            self.LikeCommentCountLabel.text = "like(\(self.likesCount ?? 0 ))"
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
    func bind(item : CommentModel.Datum,viewModel:CommentViewModeling?){
        
        self.messageTxtView.text = item.text!.decodeHtmlEntities()
        self.timeLbl.text = item.timeText!
        self.commentId = item.id ?? 0
        self.likesCount = item.likes ?? 0
        self.commentItem = item

        
        if(item.username != nil){
            self.usernameLbl.text = item.username!.decodeHtmlEntities()
        }
        self.LikeCommentCountLabel.text = "like(\(item.likes ?? 0))"
        self.replyBtn.setTitle("reply(\(item.replies ?? 0))", for: .normal)
        if item.isLiked ?? 0 == 1 {
            self.likeBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
        }else{
            self.likeBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
        }
        
        
//        self.profileImgView.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { _ in
//                viewModel.selectUserItem.accept(item.user_id!)
//            }).disposed(by: self.disposeBag)
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.avatar!) {
            self.profileImgView.image = profImg
        }else{
            self.profileImgView.sd_setImage(with: URL(string:item.avatar!),
                                            placeholderImage: UIImage(named: "img_circular_placeholder")) {  (image, error, cacheType, url) in
                                                
                                                
                                                if error != nil {
                                                    self.profileImgView.image = UIImage(named: "img_profile_placeholder")
                                                }else{
                                                    SDImageCache.shared.store(image, forKey: item.avatar!, completion: {
                                                        self.profileImgView.image = image
                                                    })
                                                }
                                                
                                                
            }
        }
    }
    func replyCommentbind(item : CommentreplyModel.Datum,viewModel:CommentViewModeling?){
        self.messageTxtView.text = item.text!.decodeHtmlEntities()
        self.timeLbl.text = item.textTime!
        self.commentId = item.id ?? 0
        self.likesCount = item.likes ?? 0
        self.replyCommentItem = item
        self.commentId = item.id

        self.replyBtn.isHidden = true
        if(item.username != nil){
            self.usernameLbl.text = item.username!.decodeHtmlEntities()
        }
        self.LikeCommentCountLabel.text = "like(\(item.likes ?? 0))"
        if item.isLiked ?? 0 == 1 {
            self.likeBtn.setImage(UIImage(named: "ic_like_active"), for: UIControl.State.normal)
        }else{
            self.likeBtn.setImage(UIImage(named: "ic_like_inactive"), for: UIControl.State.normal)
        }
        
        
        //        self.profileImgView.rx
        //            .tapGesture()
        //            .when(.recognized)
        //            .subscribe(onNext: { _ in
        //                viewModel.selectUserItem.accept(item.user_id!)
        //            }).disposed(by: self.disposeBag)
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.avatar!) {
            self.profileImgView.image = profImg
        }else{
            self.profileImgView.sd_setImage(with: URL(string:item.avatar!),
                                            placeholderImage: UIImage(named: "img_circular_placeholder")) {  (image, error, cacheType, url) in
                                                
                                                
                                                if error != nil {
                                                    self.profileImgView.image = UIImage(named: "img_profile_placeholder")
                                                }else{
                                                    SDImageCache.shared.store(image, forKey: item.avatar!, completion: {
                                                        self.profileImgView.image = image
                                                    })
                                                }
                                                
                                                
            }
        }
    }
    
    
    
    
    
}
