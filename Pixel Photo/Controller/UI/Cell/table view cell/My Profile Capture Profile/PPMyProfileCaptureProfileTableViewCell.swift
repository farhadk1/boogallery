//
//  PPMyProfileCaptureProfileTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 27/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import IoniconsSwift
import SDWebImage
import PixelPhotoSDK

class PPMyProfileCaptureProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captureImgView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImgView.isCircular()
        self.captureImgView.isCircular()
        
        self.captureImgView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
        self.cameraImageView.image = Ionicons.camera.image(20.0, color: UIColor.white)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func bind(vc : PPEditProfileViewController,viewModel:EditProfileViewModeling){
        
        if viewModel.mode == EDITPROFILEMODE.REG {

        }else{
            viewModel.profileUrl
                .asDriver()
                .drive(onNext : { value in
                    self.profileImgView.sd_setImage(with: URL(string: value),
                                                    placeholderImage: UIImage(named: "img_circular_placeholder")) {  (image, error, cacheType, url) in


                                                        if error != nil {
                                                            self.profileImgView.image = UIImage(named: "img_profile_placeholder")
                                                        }else{
                                                            SDImageCache.shared.store(image, forKey:  value, completion: {
                                                                self.profileImgView.image = image
                                                            })
                                                        }


                    }
                }).disposed(by: self.disposeBag)

        }
        
        
                viewModel.profileImage
                    .asDriver(onErrorJustReturn: nil)
                    .drive(onNext : { img in
        
                        if img == nil {
                            self.profileImgView.image = UIImage(named: "img_profile_placeholder")
                        }else{
                            self.profileImgView.image = img
                        }
        
                    }).disposed(by: self.disposeBag)
        
        viewModel.profileUrl
            .asDriver(onErrorJustReturn: "")
            .drive(onNext : { img in
                print(URL(fileURLWithPath: img).absoluteString)
                if img == "" {
                    self.profileImgView.image = UIImage(named: "img_profile_placeholder")
                }else{
                    self.profileImgView.image = UIImage(contentsOfFile: URL(fileURLWithPath: img).absoluteString)
                }

            }).disposed(by: self.disposeBag)
        
        self.captureImgView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                vc.showImagePicker()
            }).disposed(by: self.disposeBag)
    }
    
}
