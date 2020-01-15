//
//  PPSenderChatItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 07/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoSDK

class PPSenderChatItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.messageTxtView.isRoundedRect(cornerRadius: 10)
        
        self.messageTxtView.layer.cornerRadius = 10
        self.messageTxtView.layer.borderColor = UIColor.clear.cgColor
        self.messageTxtView.layer.borderWidth = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    
}
