//
//  PPStoryItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
import PixelPhotoFramework
import PixelPhotoSDK
class PPStoryItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var profileImgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImgView.isCircular(borderColor: UIColor.mainColor)
        self.profileImg.isCircular(borderColor: UIColor.clear)
    }
    
    func bind(item : StoryItem,row : Int){
        
        self.profileNameLbl.text = item.username!
        
        self.profileImg.sd_setImage(with: URL(string: item.avatar!),
                                    placeholderImage: UIImage(named: "img_profile_placeholder")) {  (image, error, cacheType, url) in
                                        
                                        
                                        if error != nil {
                                            self.profileImg.image = UIImage(named: "img_profile_placeholder")
                                        }else{
                                            self.profileImg.image = image!
                                        }
                                        
                                        
        }
    }
    
}
