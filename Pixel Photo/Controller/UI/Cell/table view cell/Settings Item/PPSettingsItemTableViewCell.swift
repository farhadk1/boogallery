//
//  PPSettingsItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoSDK

class PPSettingsItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var iconImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
