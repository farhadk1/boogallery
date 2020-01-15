//
//  PPMyProfileITemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 17/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SDWebImage
import IoniconsSwift
import PixelPhotoSDK

class PPMyProfileITemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var captureBtn: UIView!
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var numFollowerLbl: UILabel!
    
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var numFollowingLbl: UILabel!
    
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var numFavoriteLbl: UILabel!
    
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var profileFullNameLbl: UILabel!
    @IBOutlet weak var profileUsernameLbl: UILabel!
    
    @IBOutlet weak var captureView: UIView!
    
    var onFollowingClicked: (() -> Void)?
    var onFollowerClicked: (() -> Void)?
    var onFavoriteClicked: (() -> Void)?
    var onEditProfile: (() -> Void)?
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.editBtn.setTitle(NSLocalizedString("Edit Profile", comment: ""), for: UIControl.State.normal)
        self.followersLbl.text = NSLocalizedString("Followers", comment: "")
        self.followingLbl.text = NSLocalizedString("Following", comment: "")
        self.postLbl.text = NSLocalizedString("Posts", comment: "")
        
        self.profileImgView.isCircular()
        self.captureView.isCircular()
        self.captureBtn.backgroundColor = UIColor.mainColor
        self.cameraImageView.image = Ionicons.camera.image(10.0, color: UIColor.white)
        self.editBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
        self.editBtn.roundedRect(cornerRadius: 10, borderColor: UIColor.mainColor)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    func bind(viewModel : ProfileViewModeling){
        
        self.editBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.onEditProfile!()
            }).disposed(by:self.disposeBag)
        
        viewModel.profileUrl
            .asDriver()
            .drive(onNext : { img in
                self.profileImgView.image = UIImage(contentsOfFile: img)
            }).disposed(by: self.disposeBag)
        
        self.followingView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                self.onFollowingClicked!()
            }).disposed(by: self.disposeBag)
        
        self.followerView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                self.onFollowerClicked!()
            }).disposed(by: self.disposeBag)
        
        self.profileImgView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                viewModel.showImageMenu.accept(true)
            }).disposed(by: self.disposeBag)
        
        if viewModel.userItem.value != nil {
            if viewModel.userItem.value?.fname! == "" {
                self.profileFullNameLbl.text = "\(viewModel.userItem.value!.username ?? "")"
                self.profileUsernameLbl.text = "@\(viewModel.userItem.value!.username ?? "")"
            } else {
                self.profileFullNameLbl.text = "\(viewModel.userItem.value!.fname ?? "") \(viewModel.userItem.value!.lname ?? "")"
                self.profileUsernameLbl.text = "@\(viewModel.userItem.value!.username ?? "")"
            }
            
            if viewModel.userItem.value?.about == nil || viewModel.userItem.value?.about == "" {
                self.descLbl.text = "Hi There I'm using Pixel Photo."
            }else{
                self.descLbl.text = viewModel.userItem.value?.about!.decodeHtmlEntities()
            }
            
            self.numFollowerLbl.text = "\(viewModel.userItem.value!.followers!)"
            self.numFollowingLbl.text = "\(viewModel.userItem.value!.following!)"
            self.numFavoriteLbl.text = "\(viewModel.userItem.value!.posts_count!)"
            
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
        }
    }
    
}
