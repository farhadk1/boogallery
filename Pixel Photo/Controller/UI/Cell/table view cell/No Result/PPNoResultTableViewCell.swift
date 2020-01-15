//
//  PPNoResultTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import PixelPhotoSDK

class PPNoResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var searchRandomView: GradientView!
    @IBOutlet weak var sadLbl: UILabel!
    @IBOutlet weak var mistakeSpellingLbl: UILabel!
    @IBOutlet weak var searchRandomLbl: UILabel!
    
    var disposeBag = DisposeBag()
    var vc:SearchVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.sadLbl.text = NSLocalizedString("Sad no result!", comment: "")
        self.mistakeSpellingLbl.text = NSLocalizedString("We cannot find the keyword you are searching form maybe a little spelling mistake?", comment: "")
        self.searchRandomLbl.text = NSLocalizedString("Search Random", comment: "")
        
        let searchTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(seachRandomTapped(tapGestureRecognizer:)))
        searchRandomView.isUserInteractionEnabled = true
        searchRandomView.addGestureRecognizer(searchTapGestureRecognizer)
    }
    @objc func seachRandomTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.vc?.search(KeyWord: "a")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
