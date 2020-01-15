//
//  PPSubmitButtonItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 27/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoSDK

class PPSubmitButtonItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var submitView: GradientView!
    @IBOutlet weak var saveAndContinueBtn: UILabel!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.saveAndContinueBtn.text = NSLocalizedString("Save & Continue", comment: "")
        
        self.submitView.roundedRect(cornerRadius: 20, borderColor: UIColor.clear)
        self.submitView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func bind(viewModel : EditProfileViewModeling){
        
        self.submitView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                viewModel.submitButton.accept(true)
            }).disposed(by: self.disposeBag)
    }
}
