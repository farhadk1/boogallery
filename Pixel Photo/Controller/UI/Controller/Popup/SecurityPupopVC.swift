//
//  SecurityPupopVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import SwiftEventBus
import PixelPhotoSDK

class SecurityPopupVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorTextLabel: UILabel!
    
    var errorText:String? = ""
    var titleText:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    private func setupUI(){
        self.titleLabel.text = titleText ?? "Security"
        self.errorTextLabel.text = errorText ?? "N/A"
    }
    @IBAction func okPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
