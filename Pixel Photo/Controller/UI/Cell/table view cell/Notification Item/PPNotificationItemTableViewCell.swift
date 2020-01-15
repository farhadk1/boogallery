//
//  PPNotificationItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 08/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
import PixelPhotoFramework
import PixelPhotoSDK

class PPNotificationItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var addProfileView: UIView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
   
    
}
