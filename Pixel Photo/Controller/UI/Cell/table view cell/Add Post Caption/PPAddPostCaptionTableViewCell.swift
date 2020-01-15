//
//  PPAddPostCaptionTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 13/01/2019.
//  Copyright © 2019DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SDWebImage
import PixelPhotoFramework
import PixelPhotoSDK

class PPAddPostCaptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileTypeLbl: UILabel!
    @IBOutlet weak var profileTypeContainerView: UIView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionTextViewHeightContraints: NSLayoutConstraint!
    @IBOutlet weak var mentionedTxtView: UITextView!
    @IBOutlet weak var mentionedTxtViewHeightConstraints: NSLayoutConstraint!
    private let placeholder = NSLocalizedString("Add post caption. #hashtag..@mention?", comment: "")
    
    var tblview:UITableView?
    var disposeBag = DisposeBag()
    var type:String? = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImgView.isCircular()
        
        self.captionTextView.delegate = self
        self.mentionedTxtView.delegate = self
        self.captionTextView.text = placeholder
        
        self.profileTypeContainerView.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        self.profileTypeContainerView.isRoundedRect(cornerRadius: 20)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(tblview:UITableView){
        
        self.tblview = tblview

        
        self.adjustHeight()
        
        if AppInstance.instance.userProfile?.data?.name ?? "" .replacingOccurrences(of: " ", with: "") == "" {
            self.profileNameLbl.text = "You"
        } else {
            self.profileNameLbl.text = AppInstance.instance.userProfile?.data?.name ?? ""
        }
        
        if type == "GIF" {
            self.profileTypeLbl.text = "GIF"
        }else if type == "IMAGE" {
            self.profileTypeLbl.text = "Images"
        }else if type == "YOUTUBE" {
            self.profileTypeLbl.text = "Embed Video"
        }else if type == "VIDEO" {
            self.profileTypeLbl.text = "Video"

            
        }
        
        
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:AppInstance.instance.userProfile?.data?.avatar ?? "") {
            self.profileImgView.image = profImg
        }else{
            self.profileImgView.sd_setImage(with: URL(string:(AppInstance.instance.userProfile?.data?.avatar ?? "")),
                                            placeholderImage: UIImage(named: "img_circular_placeholder")) {  (image, error, cacheType, url) in
                                                
                                                
                                                if error != nil {
                                                    self.profileImgView.image = UIImage(named: "img_profile_placeholder")
                                                }else{
                                                    SDImageCache.shared.store(image, forKey: AppInstance.instance.userProfile?.data?.avatar ?? "", completion: {
                                                        self.profileImgView.image = image
                                                    })
                                                }
                                                
                                                
            }
        }
        
//        viewModel.captionText
//            .asDriver(onErrorJustReturn: "")
//            .drive(onNext : { value in
//                print(value)
//            }).disposed(by: self.disposeBag)
    }
    
    func adjustHeight(){
        self.tblview?.beginUpdates()
        let size = self.captionTextView.sizeThatFits(CGSize(width: self.captionTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        captionTextViewHeightContraints.constant = size.height
        self.setNeedsLayout()
        self.captionTextView.setContentOffset(CGPoint.zero, animated: false)
        
        let size2 = self.mentionedTxtView.sizeThatFits(CGSize(width: self.mentionedTxtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        mentionedTxtViewHeightConstraints.constant = size2.height
        self.setNeedsLayout()
        self.mentionedTxtView.setContentOffset(CGPoint.zero, animated: false)
        self.tblview?.endUpdates()
    }
}

extension PPAddPostCaptionTableViewCell : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = placeholder
        }
        
        self.adjustHeight()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
        }else{
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholder
        }else{
            
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
        return true
    }
    
}
