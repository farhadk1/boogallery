//
//  ContactsTableCell.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 30/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import PixelPhotoSDK

class ContactsTableCell: UITableViewCell {
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
