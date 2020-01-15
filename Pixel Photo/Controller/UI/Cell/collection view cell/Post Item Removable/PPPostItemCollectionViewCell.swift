//
//  PPPostItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 14/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SDWebImage
import WebKit
import PixelPhotoSDK
class PPPostItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var itemWebView: WKWebView!
    
    var disposeBag = DisposeBag()
    var bindingType:String? = ""
    var vc:AddPostPostVC?
    var index:Int? = 0
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    @IBAction func crossPressed(_ sender: Any) {
       self.vc?.isEmptyMedia = true
        if bindingType == "IMAGE"{
            self.vc?.imageArray.remove(at: self.index ?? 0)
            self.vc?.collectionView.reloadData()
        }else if  bindingType == "GIF"{
            self.vc?.GifsArray.remove(at: self.index ?? 0)
            self.vc?.collectionView.reloadData()
            
        } else if bindingType == "VIDEO"{
            self.vc?.thumbnailiamgeArray.remove(at: self.index ?? 0)
             self.vc?.videoArray.remove(at: self.index ?? 0)
            self.vc?.collectionView.reloadData()
        }
    }
  
    func imageBinding(image : UIImage,row:Int,Type:String){
        self.index = row
         self.bindingType = Type
            self.itemWebView.isHidden = true
            self.itemImageView.image = image
        self.bringSubviewToFront(self.removeBtn)
    }
    func videoBinding(videoThumb:UIImage,row:Int,Type:String){
        self.index = row
         self.bindingType = Type
        self.itemWebView.isHidden = true
        self.itemImageView.image = videoThumb
        
    }
    func gifBinding(gifURL:String,row:Int,Type:String){
        self.index = row
        self.bindingType = Type
        self.itemWebView.isHidden = false
        self.itemImageView.isHidden = true
        let htmlString = "<html style=\"margin: 0;\"><body style=\"margin: 0;\"><img src=\"\(gifURL)\" style=\"width: 100%; height: 100%\" /></body></html>"
        self.itemWebView.loadHTMLString(htmlString, baseURL: nil)
    }
}
