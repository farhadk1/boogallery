//
//  PPUserProfileThumbnailItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 27/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import PixelPhotoFramework
import PixelPhotoSDK

class PPUserProfileThumbnailItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    
    var disposeBag = DisposeBag()
    
    var item: UserModel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImgView.isCircular()
        self.containerView.addShadow()
        
        self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.followBtn.layer.frame = self.followBtn.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if item != nil {
            if item.is_following == true {
                self.followBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
                self.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                self.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
            }else{
                self.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                self.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                self.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
            }
        }
        
    }
    
    func bind(viewModel : SuggestionUserViewModeling,item: UserModel){
        self.item = item
        self.userNameLbl.text = item.username!
        
        if item.fname! == "" ||  item.lname! == "" {
            self.profileNameLbl.text = "Anonymous"
        }else{
            self.profileNameLbl.text = "\(item.fname!) \(item.lname!)"
        }
        
        self.layoutSubviews()
        
        self.profileImgView.sd_setImage(with: URL(string: item.avatar!),
                                        placeholderImage: UIImage(named: "img_profile_placeholder")) {  (image, error, cacheType, url) in
                                            
        }
        
        self.followBtn.rx.tap
            .asDriver()
            .flatMapLatest({ () -> Driver<Bool> in
                return viewModel.followUnfollowUser(user: self.item).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                if value {
                    item.is_following = true
                }else{
                    item.is_following = false
                }
                self.layoutSubviews()
            }).disposed(by: self.disposeBag)
    }
    
    func bind(viewModel : ExploreViewModeling,item: UserModel){
        self.item = item
        self.userNameLbl.text = item.username!
        
        if item.fname! == "" ||  item.lname! == "" {
            self.profileNameLbl.text = item.username ?? ""
        }else{
            self.profileNameLbl.text = "\(item.fname!) \(item.lname!)"
        }
        
        self.layoutSubviews()
        
        self.profileImgView.sd_setImage(with: URL(string: item.avatar!),
                                        placeholderImage: UIImage(named: "img_profile_placeholder")) {  (image, error, cacheType, url) in
                                            
        }
        
        self.followBtn.rx.tap
            .asDriver()
            .flatMapLatest({ () -> Driver<Bool> in
                return viewModel.followUnfollowUser(user: self.item).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                if value {
                    item.is_following = true
                }else{
                    item.is_following = false
                }
                self.layoutSubviews()
            }).disposed(by: self.disposeBag)
    }
    
}
