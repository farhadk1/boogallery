//
//  EmbbedVideoVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 17/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import PixelPhotoSDK

class EmbbedVideoVC: UIViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var urlTxtView: UITextView!
    @IBOutlet weak var embedLbl: UILabel!
    
    var delegate:didSelectEmbbedVideoDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didSelectEmbbedVideo(videoURL: self.urlTxtView.text ?? "")
        }
    }
    func setupUI(){
        self.embedLbl.text = NSLocalizedString("Embed Video", comment: "")
        self.cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControl.State.normal)
        self.submitBtn.setTitle(NSLocalizedString("Submit", comment: ""), for: UIControl.State.normal)
    }
}
