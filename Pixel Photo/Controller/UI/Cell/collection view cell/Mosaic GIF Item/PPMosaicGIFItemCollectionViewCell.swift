//
//  PPMosaicGIFItemCollectionViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import SDWebImage
//import SwiftyGif
import RxSwift
import RxCocoa
import PixelPhotoFramework
import WebKit
import PixelPhotoSDK
class PPMosaicGIFItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentWebView: UIWebView!
    @IBOutlet weak var typeImgView: UIImageView!
    //@IBOutlet weak var contentGIFImgView: UIImageView!
    
    var isPlaying = false
    
    var disposeBag = DisposeBag()
    
    fileprivate var item:PostItem?
    fileprivate var giphyItem : GiphyItem?
    fileprivate var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentWebView.isUserInteractionEnabled = false
        //self.contentGIFImgView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("PPMosaicGIFItemCollectionViewCell : prepareForReuse")
        
     
        self.disposeBag = DisposeBag()
    }
    
    deinit {
        print("PPMosaicGIFItemCollectionViewCell : Deinit")
        // SwiftyGifManager.defaultManager.clear()
    }
    
    
    
    func bind(item:GiphyItem,indexPath:IndexPath){
        
        self.giphyItem = item
        self.indexPath = indexPath
        
        self.typeImgView.image = UIImage(named: "ic_type_gif")
        
        DispatchQueue.main.async {
            let htmlString = "<html style=\"margin: 0;\"><body style=\"margin: 0;\"><img src=\"\(item.images!.fixed_height_still!.url!)\" style=\"width: 100%; height: 100%\" /></body></html>"
            self.contentWebView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    func bindGif(item:GIFModel.Datum,indexPath:IndexPath){
        
        self.indexPath = indexPath
        
        self.typeImgView.image = UIImage(named: "ic_type_gif")
        
        DispatchQueue.main.async {
            let htmlString = "<html style=\"margin: 0;\"><body style=\"margin: 0;\"><img src=\"\(item.images?.fixedHeightStill?.url ?? "")\" style=\"width: 100%; height: 100%\" /></body></html>"
            self.contentWebView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    func bind(item:ExplorePostModel.Datum,indexPath:IndexPath){
        
//        self.item = item
        self.indexPath = indexPath
        
        self.typeImgView.image = UIImage(named: "ic_type_gif")
        
        DispatchQueue.main.async {
            let htmlString = "<html style=\"margin: 0;\"><body style=\"margin: 0;\"><img src=\"\(item.mediaSet![0].file!)\" style=\"width: 100%; height: 100%\" /></body></html>"
            self.contentWebView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    func bindUserPost(item:FetchPostModel.UserPost,indexPath:IndexPath){
        
        //        self.item = item
        self.indexPath = indexPath
        
        self.typeImgView.image = UIImage(named: "ic_type_gif")
        
        DispatchQueue.main.async {
            let htmlString = "<html style=\"margin: 0;\"><body style=\"margin: 0;\"><img src=\"\(item.mediaSet![0].file!)\" style=\"width: 100%; height: 100%\" /></body></html>"
            self.contentWebView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    func bindfavoritePost(item:FavoriteModel.Datum,indexPath:IndexPath){
        
        //        self.item = item
        self.indexPath = indexPath
        
        self.typeImgView.image = UIImage(named: "ic_type_gif")
        
        DispatchQueue.main.async {
            let htmlString = "<html style=\"margin: 0;\"><body style=\"margin: 0;\"><img src=\"\(item.mediaSet![0].file!)\" style=\"width: 100%; height: 100%\" /></body></html>"
            self.contentWebView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
}

