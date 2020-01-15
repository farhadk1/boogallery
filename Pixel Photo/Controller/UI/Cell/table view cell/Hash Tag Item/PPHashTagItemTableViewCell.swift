//
//  PPHashTagItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 10/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoSDK

class PPHashTagItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var hashView: UIView!
    @IBOutlet weak var hashLbl: UILabel!
    @IBOutlet weak var numHashLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.hashView.isCircular()
        self.hashView.backgroundColor = UIColor.mainColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
//    
//    func bind(hashItem : HashItem){
//        self.hashLbl.text = "\(hashItem.tag!)"
//        self.numHashLbl.text = "\(hashItem.use_num!) \(NSLocalizedString("Post", comment: ""))"
//    }
//    
}
