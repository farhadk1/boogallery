//
//  PPMosaicImageItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
import PixelPhotoFramework
import PixelPhotoSDK
class PPMosaicImageItemCollectionViewCell: UICollectionViewCell {
    
    var loaded = false
    
    @IBOutlet weak var typeImgView: UIImageView!
    @IBOutlet weak var contentImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func bind(item : ExplorePostModel.Datum){
        
        if item.type == "image" {
            self.typeImgView.image = UIImage(named: "ic_type_image")
        }else{
            self.typeImgView.image = UIImage(named: "ic_type_link")
        }
        
        if item.mediaSet![0].extra! == "" {
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].file!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].file!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }else{
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].extra!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }
        
        
    }
    func bindUserPost(item : FetchPostModel.UserPost){
        
        if item.type == "image" {
            self.typeImgView.image = UIImage(named: "ic_type_image")
        }else{
            self.typeImgView.image = UIImage(named: "ic_type_link")
        }
        
        if item.mediaSet![0].extra! == "" {
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].file!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].file!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }else{
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].extra!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }
        
        
    }
    func bindFavoritePost(item : FavoriteModel.Datum){
        
        if item.type == "image" {
            self.typeImgView.image = UIImage(named: "ic_type_image")
        }else{
            self.typeImgView.image = UIImage(named: "ic_type_link")
        }
        
        if item.mediaSet![0].extra! == "" {
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].file!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].file!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }else{
            if let image = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra!) {
                self.contentImgView.image = image
            }else{
                self.contentImgView.sd_setImage(with: URL(string: item.mediaSet![0].extra!),
                                                placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].file!, completion: {
                                                            self.contentImgView.image = image
                                                        })
                                                    }
                                                    
                                                    
                }
            }
        }
        
        
    }
    
    
    
    func bind(item : String,type:String){
        
        if type == "video" {
            self.typeImgView.image = UIImage(named: "ic_type_video")
        }else if type == "image" {
            self.typeImgView.image = UIImage(named: "ic_type_image")
        }else if type == "gif" {
            self.typeImgView.image = UIImage(named: "ic_type_gif")
        }else{
            self.typeImgView.image = UIImage(named: "ic_type_link")
        }
        
        
        if let image = SDImageCache.shared.imageFromCache(forKey:item) {
            DispatchQueue.main.async {
                let aspectRatio = self.frame.size.height / self.frame.size.width
                self.contentImgView.image = image.resizeImage(aspectRation: aspectRatio)
            }
        }else{
            self.contentImgView.sd_setImage(with: URL(string: item),
                                            placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                
                                                
                                                if error != nil {
                                                    self.contentImgView.image = UIImage(named: "img_item_placeholder")
                                                }else{
                                                    SDImageCache.shared.store(image, forKey: item, completion: {
                                                        DispatchQueue.main.async {
                                                            let aspectRatio = self.frame.size.height / self.frame.size.width
                                                            self.contentImgView.image = image!.resizeImage(aspectRation: aspectRatio)
                                                        }
                                                        
                                                    })
                                                }
                                                
                                                
            }
        }
    }
}
