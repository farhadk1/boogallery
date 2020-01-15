//
//  PPProfileItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 22/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import PixelPhotoSDK
import PixelPhotoFramework
class PPProfileItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var numFollowerLbl: UILabel!
    @IBOutlet weak var numFollowingLbl: UILabel!
    @IBOutlet weak var numFavoritesLbl: UILabel!
    
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var followersView: UIView!
    
    var disposeBag = DisposeBag()
    
    var user:UserModel?
    
    var onFollowingClicked: (() -> Void)?
    var onFollowerClicked: (() -> Void)?
    var onFavoriteClicked: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        self.profileImgView.isCircular()
        
        self.blockBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
        self.messageBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.user != nil {
            if self.user!.is_following == true {
                self.followBtn.isRoundedRect(cornerRadius: 10, hasBorderColor: UIColor.clear)
                self.followBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
                self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                self.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            }else{
                self.followBtn.isRoundedRect(cornerRadius: 10, hasBorderColor: UIColor.clear)
                self.followBtn.applyGradient(colours: [UIColor.lightGray.withAlphaComponent(0.4) , UIColor.lightGray.withAlphaComponent(0.4)], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
                self.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                self.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
                self.followBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    func bind(viewModel:ProfileViewModeling){
        
        if viewModel.userItem.value != nil {
            
            self.followBtn.rx.tap
                .throttle(0.3, scheduler: MainScheduler.instance)
                .flatMapLatest({ () -> Observable<Bool> in
                    return viewModel.followUnfollowUser(user: viewModel.userItem.value!)
                })
                .subscribe(onNext : { value in
                    let temp = viewModel.userItem.value
                    if value {
                        temp?.is_following = true
                        viewModel.userItem.accept(temp)
                    }else{
                        temp?.is_following = false
                        viewModel.userItem.accept(temp)
                    }
                    self.setNeedsLayout()
                }).disposed(by:self.disposeBag)
            
            self.messageBtn.rx.tap
                .throttle(0.3, scheduler: MainScheduler.instance)
                .subscribe({ _ in
                    viewModel.messageuser.accept(viewModel.userItem.value!)
                }).disposed(by:self.disposeBag)
            
            self.blockBtn.rx.tap
                .throttle(0.3, scheduler: MainScheduler.instance)
                .subscribe({ _ in
                    viewModel.blockUser.accept(true)
                }).disposed(by:self.disposeBag)
            
            self.followingView.rx
                .tapGesture()
                .when(.recognized)
                .subscribe({ _ in
                    self.onFollowingClicked!()
                }).disposed(by: self.disposeBag)
            
            self.followersView.rx
                .tapGesture()
                .when(.recognized)
                .subscribe({ _ in
                    self.onFollowerClicked!()
                }).disposed(by: self.disposeBag)
            
            self.user = viewModel.userItem.value
            
            if viewModel.userItem.value?.about != "" {
                self.bioLbl.text = viewModel.userItem.value?.about!.decodeHtmlEntities()
            }else {
                self.bioLbl.text = "Hi There I'm using Pixel Photo."
            }
            
            if viewModel.userItem.value?.fname! == "" {
                self.fullnameLbl.text = "\(viewModel.userItem.value!.username ?? "")"
                self.usernameLbl.text = "@\(viewModel.userItem.value!.username ?? "")"
            } else {
                self.fullnameLbl.text = "\(viewModel.userItem.value!.fname ?? "") \(viewModel.userItem.value!.lname ?? "")"
                self.usernameLbl.text = "@\(viewModel.userItem.value!.username ?? "")"
            }
            
            if let profImg = SDImageCache.shared.imageFromCache(forKey:viewModel.userItem.value!.avatar!) {
                self.profileImgView.image = profImg
            }else{
                self.profileImgView.sd_setImage(with: URL(string:viewModel.userItem.value!.avatar!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.profileImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: viewModel.userItem.value!.avatar!, completion: {
                                                            self.profileImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
            
            
            self.numFollowerLbl.text = "\(viewModel.userItem.value!.followers!)"
            self.numFollowingLbl.text = "\(viewModel.userItem.value!.following!)"
            self.numFavoritesLbl.text = "\(viewModel.userItem.value!.posts_count!)"
        }
    }
    
}
