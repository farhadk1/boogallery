//
//  PPNormalVerticalCollectionViewItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 17/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework
import PixelPhotoSDK

class PPNormalVerticalCollectionViewItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var verticalCollectionViewHeightConstraints: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    var viewModel : ProfileViewModeling?
    
    var postItem : [PostItem] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentCollectionView.dataSource = self
        self.contentCollectionView.delegate = self
        
        self.contentCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicVideoItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicImageItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicImageItemCollectionViewCellID")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func bind(items:[PostItem],viewModel:ProfileViewModeling){
        
        self.postItem = items
        self.viewModel = viewModel
        
        self.contentCollectionView.reloadData()
        
        self.verticalCollectionViewHeightConstraints.constant = self.contentCollectionView.contentSize.height
        self.setNeedsLayout()
    }
    
}

extension PPNormalVerticalCollectionViewItemTableViewCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 , height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.postItem[indexPath.row]
        
        if item.type == "video" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID", for: indexPath) as! PPMosaicVideoItemCollectionViewCell
//            cell.bind(item: item)
            return cell
        }else if item.type == "image" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
//            cell.bind(item: item)
            return cell
        }else if item.type == "gif" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID", for: indexPath) as! PPMosaicGIFItemCollectionViewCell
//            cell.bind(item: item,indexPath: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
//        cell.bind(item: item)
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.showPost.accept(self.postItem[indexPath.row])
    }
    
}
