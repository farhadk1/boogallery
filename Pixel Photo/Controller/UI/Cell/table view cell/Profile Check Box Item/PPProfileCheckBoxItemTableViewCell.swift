//
//  PPProfileCheckBoxItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 11/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import BEMCheckBox
import PixelPhotoFramework
import Async
import PixelPhotoSDK


class PPProfileCheckBoxItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    
    var vcFollowers:FollowersVC?
    var vcFollowings:FollowingVC?
    var vcLikes:LikesVC?
    var vcSearch:SearchVC?

    var userId : Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    @IBAction func followPressed(_ sender: Any) {
        followUnFollow()
    }
    private func followUnFollow(){
        if vcFollowers  != nil {
            if self.vcFollowers!.appDelegate.isInternetConnected{
                let accessToken = AppInstance.instance.accessToken ?? ""
                let userID = self.userId ?? 0
                Async.background({
                    FollowUnFollowManager.instance.followUnFollow(accessToken: accessToken, userId: userID, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("Success = \(success?.type!)")
                                if success?.type ?? 0 == 1{
                                    
                                    self.followBtn.backgroundColor = UIColor.startColor
                                    self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                                }else{
                                    //                                self.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                                    self.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
                                }
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                
                                log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                                self.vcFollowers!.view.makeToast(sessionError?.errors?.errorText ?? "")
                            })
                            
                        }else {
                            Async.main({
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.vcFollowers!.view.makeToast(error?.localizedDescription ?? "")
                            })
                        }
                    })
                })
            }else{
                log.error(InterNetError)
                self.vcFollowers!.view.makeToast(InterNetError)
            }
        }else if vcFollowings != nil{
            if self.vcFollowings!.appDelegate.isInternetConnected{
                let accessToken = AppInstance.instance.accessToken ?? ""
                let userID = self.userId ?? 0
                Async.background({
                    FollowUnFollowManager.instance.followUnFollow(accessToken: accessToken, userId: userID, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("Success = \(success?.type!)")
                                if success?.type ?? 0 == 1{
                                    
                                    self.followBtn.backgroundColor = UIColor.startColor
                                    self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                                }else{
                                    //                                self.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                                    self.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
                                }
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                
                                log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                                self.vcFollowings!.view.makeToast(sessionError?.errors?.errorText ?? "")
                            })
                            
                        }else {
                            Async.main({
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.vcFollowings!.view.makeToast(error?.localizedDescription ?? "")
                            })
                        }
                    })
                })
            }else{
                log.error(InterNetError)
                self.vcFollowings!.view.makeToast(InterNetError)
            }
        }else if vcLikes != nil{
            if self.vcLikes!.appDelegate.isInternetConnected{
                let accessToken = AppInstance.instance.accessToken ?? ""
                let userID = self.userId ?? 0
                Async.background({
                    FollowUnFollowManager.instance.followUnFollow(accessToken: accessToken, userId: userID, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("Success = \(success?.type!)")
                                if success?.type ?? 0 == 1{
                                    
                                    self.followBtn.backgroundColor = UIColor.startColor
                                    self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                                }else{
                                    //                                self.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                                    self.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
                                }
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                
                                log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                                self.vcLikes!.view.makeToast(sessionError?.errors?.errorText ?? "")
                            })
                            
                        }else {
                            Async.main({
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.vcLikes!.view.makeToast(error?.localizedDescription ?? "")
                            })
                        }
                    })
                })
            }else{
                log.error(InterNetError)
                self.vcLikes!.view.makeToast(InterNetError)
            }
            
        }else if vcSearch != nil{
            if self.vcSearch!.appDelegate.isInternetConnected{
                let accessToken = AppInstance.instance.accessToken ?? ""
                let userID = self.userId ?? 0
                Async.background({
                    FollowUnFollowManager.instance.followUnFollow(accessToken: accessToken, userId: userID, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("Success = \(success?.type!)")
                                if success?.type ?? 0 == 1{
                                    
                                    self.followBtn.backgroundColor = UIColor.startColor
                                    self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                                }else{
                                    //                                self.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                                    self.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                                    self.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
                                }
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                
                                log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                                self.vcSearch!.view.makeToast(sessionError?.errors?.errorText ?? "")
                            })
                            
                        }else {
                            Async.main({
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.vcSearch!.view.makeToast(error?.localizedDescription ?? "")
                            })
                        }
                    })
                })
            }else{
                log.error(InterNetError)
                self.vcSearch!.view.makeToast(InterNetError)
            }
            
        }
        
    }
}

