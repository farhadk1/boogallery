//
//  PPInputTextFieldItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 27/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import ActionSheetPicker_3_0
import PixelPhotoSDK

class PPInputTextFieldItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textFid: UITextField!
    var viewModel:EditProfileViewModeling?
    var disposeBag = DisposeBag()
    
    var genderSelection = [NSLocalizedString("Male", comment: ""),NSLocalizedString("Female", comment: "")]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(row:Int,viewModel:EditProfileViewModeling){
        
        self.viewModel = viewModel
        
        if row == 1 {
            self.textFid.placeholder = NSLocalizedString("First Name", comment: "")
            self.textFid.rx.text.orEmpty.bind(to: viewModel.fnameTxt).disposed(by: self.disposeBag)
            //self.textFid.text = viewModel.user?.fname!
        } else if row == 2 {
            self.textFid.placeholder = NSLocalizedString("Last Name", comment: "")
            self.textFid.rx.text.orEmpty.bind(to: viewModel.lnameTxt).disposed(by: self.disposeBag)
            //self.textFid.text = viewModel.user?.lname!
        } else if row == 3 {
            self.textFid.placeholder = NSLocalizedString("About you", comment: "")
            self.textFid.rx.text.orEmpty.bind(to: viewModel.aboutTxt).disposed(by: self.disposeBag)
            //self.textFid.text = viewModel.user?.about!
        } else if row == 4 {
            self.textFid.delegate = self
            self.textFid.placeholder = NSLocalizedString("Gender", comment: "")
            self.textFid.rx.text.orEmpty.bind(to: viewModel.genderTxt).disposed(by: self.disposeBag)
            // self.textFid.text = viewModel.user?.gender!.capitalizingFirstLetter()
        } else if row == 5 {
            self.textFid.placeholder = NSLocalizedString("Your Facebook profile url", comment: "")
            self.textFid.rx.text.orEmpty.bind(to: viewModel.fbUrlTxt).disposed(by: self.disposeBag)
            //self.textFid.text = viewModel.user?.facebook!
        } else if row == 6 {
            self.textFid.placeholder = NSLocalizedString("Your Google Plus profile url", comment: "")
            self.textFid.rx.text.orEmpty.bind(to: viewModel.googleUrlTxt).disposed(by: self.disposeBag)
            // self.textFid.text = viewModel.user?.google!
        }
    }
    
    func showGenderSelection(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString(NSLocalizedString("Gender", comment: ""), comment: ""),
                                     rows: genderSelection,
                                     initialSelection: 0,
                                     doneBlock: { (picker, value, index) in
                                        self.viewModel?.genderTxt.accept(self.genderSelection[value])
                                        self.textFid.text = String(self.genderSelection[value])
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self)
    }
    
}

extension PPInputTextFieldItemTableViewCell : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showGenderSelection()
        return false
    }
}
