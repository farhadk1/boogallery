//
//  PPMosaicVideoItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import RxCocoa
import RxSwift
import RxGesture
import PixelPhotoFramework
import PixelPhotoSDK
class PPMosaicVideoItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentVideoImgVIew: UIImageView!
    @IBOutlet weak var typeImgView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func bind(item : ExplorePostModel.Datum){
        
        self.typeImgView.image = UIImage(named: "ic_type_video")
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra) {
            self.contentVideoImgVIew.image = profImg
        }else{
            self.contentVideoImgVIew.sd_setImage(with: URL(string:item.mediaSet![0].extra!),
                                                 placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentVideoImgVIew.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].extra, completion: {
                                                            self.contentVideoImgVIew.image = image
                                                        })
                                                    }
                                                    
                                                    
            }
        }
    }
    func bindUserPost(item : FetchPostModel.UserPost){
        
        self.typeImgView.image = UIImage(named: "ic_type_video")
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra) {
            self.contentVideoImgVIew.image = profImg
        }else{
            self.contentVideoImgVIew.sd_setImage(with: URL(string:item.mediaSet![0].extra!),
                                                 placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentVideoImgVIew.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].extra, completion: {
                                                            self.contentVideoImgVIew.image = image
                                                        })
                                                    }
                                                    
                                                    
            }
        }
    }
    func bindFavoritePost(item : FavoriteModel.Datum){
        
        self.typeImgView.image = UIImage(named: "ic_type_video")
        
        if let profImg = SDImageCache.shared.imageFromCache(forKey:item.mediaSet![0].extra) {
            self.contentVideoImgVIew.image = profImg
        }else{
            self.contentVideoImgVIew.sd_setImage(with: URL(string:item.mediaSet![0].extra!),
                                                 placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                    
                                                    
                                                    if error != nil {
                                                        self.contentVideoImgVIew.image = UIImage(named: "img_item_placeholder")
                                                    }else{
                                                        SDImageCache.shared.store(image, forKey: item.mediaSet![0].extra, completion: {
                                                            self.contentVideoImgVIew.image = image
                                                        })
                                                    }
                                                    
                                                    
            }
        }
    }
    
}

