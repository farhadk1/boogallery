//
//  PPYourStoryItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoFramework
import RxCocoa
import RxSwift
import RxGesture
import SDWebImage
import PixelPhotoSDK
class PPYourStoryItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profImgContainerView: UIView!
    @IBOutlet weak var addStoryView: UIView!
    @IBOutlet weak var profileImageVIew: UIImageView!
    @IBOutlet weak var yourStoryLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.yourStoryLbl.text = NSLocalizedString("Your Story", comment: "")
        self.addStoryView.backgroundColor = UIColor.mainColor
        self.profImgContainerView.isCircular(borderColor: UIColor.mainColor)
        self.addStoryView.isCircular(borderColor: UIColor.mainColor)
        self.profileImageVIew.isCircular(borderColor: UIColor.clear)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func bind(item : UserModel){
        
        print(item.avatar!)
        
        self.profileImageVIew.contentMode = UIView.ContentMode.scaleAspectFill
        self.profileImageVIew.clipsToBounds = true
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.avatar!) {
            self.profileImageVIew.image = profImg
        }else{
            self.profileImageVIew.sd_setImage(with: URL(string:item.avatar!),
                                              placeholderImage: UIImage(named: "img_profile_placeholder")) {  (image, error, cacheType, url) in
                                                
                                                
                                                if error != nil {
                                                    self.profileImageVIew.image = UIImage(named: "img_profile_placeholder")
                                                }else{
                                                    SDImageCache.shared.store(image, forKey: item.avatar!, completion: {
                                                        self.profileImageVIew.image = image
                                                    })
                                                }
                                                
                                                
            }
        }
    }
}
