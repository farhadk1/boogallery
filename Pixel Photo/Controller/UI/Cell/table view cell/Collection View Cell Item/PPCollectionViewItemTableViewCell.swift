//
//  PPCollectionViewItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoSDK

class PPCollectionViewItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentCollectionView.register(UINib(nibName: "PPYourStoryItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPYourStoryItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPStoryItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPStoryItemCollectionViewCellID")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

extension PPCollectionViewItemTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        contentCollectionView.delegate = dataSourceDelegate
        contentCollectionView.dataSource = dataSourceDelegate
        contentCollectionView.tag = row
        contentCollectionView.setContentOffset(contentCollectionView.contentOffset, animated:false)
        contentCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { contentCollectionView.contentOffset.x = newValue }
        get { return contentCollectionView.contentOffset.x }
    }
    
}

