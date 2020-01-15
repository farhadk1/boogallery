//
//  PPChatUserItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 07/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoSDK
import SDWebImage

class PPChatUserItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImgView.isCircular()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
//    func bind(item : ChatItem){
//        
//        self.userNameLbl.text = "\(item.username!)"
//        self.timeLbl.text = "\(item.time_text!)"
//        self.messageLbl.text = "\(item.last_message!)"
//        
//        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.avatar!) {
//            self.profileImgView.image = profImg
//        }else{
//            self.profileImgView.sd_setImage(with: URL(string:item.avatar!),
//                                            placeholderImage: UIImage(named: "img_circular_placeholder")) {  (image, error, cacheType, url) in
//                                                
//                                                
//                                                if error != nil {
//                                                    self.profileImgView.image = UIImage(named: "img_profile_placeholder")
//                                                }else{
//                                                    SDImageCache.shared.store(image, forKey: item.avatar!, completion: {
//                                                        self.profileImgView.image = image
//                                                    })
//                                                }
//                                                
//                                                
//            }
//        }
//    }
    
}
