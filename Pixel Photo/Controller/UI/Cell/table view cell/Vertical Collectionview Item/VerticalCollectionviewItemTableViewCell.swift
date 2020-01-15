//
//  VerticalCollectionviewItemTableViewCell.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 08/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import TRMosaicLayout
import RxSwift
import RxCocoa
import PixelPhotoFramework
import PixelPhotoSDK

class VerticalCollectionviewItemTableViewCell: UITableViewCell {

    @IBOutlet weak var verticalCollectionViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var verticalCollectionView: UICollectionView!
    
    var viewModel : ExploreViewModeling?
    var currentIndexPath : IndexPath?
    var diposeBag = DisposeBag()
    var vc:ExploreVC?
    
    var postItems : [PostItem] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        let mosaicLayout = TRMosaicLayout()
        self.verticalCollectionView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self

         self.verticalCollectionViewHeightConstraints.constant = self.verticalCollectionView.contentSize.height
        
        self.verticalCollectionView.delegate = self
        self.verticalCollectionView.dataSource = self
        
        self.verticalCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
        self.verticalCollectionView.register(UINib(nibName: "PPMosaicVideoItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID")
        self.verticalCollectionView.register(UINib(nibName: "PPMosaicImageItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicImageItemCollectionViewCellID")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel : ExploreViewModeling){
        
        self.viewModel = viewModel
        self.postItems = (self.viewModel?.exploreItems.value)!
        
        self.layoutIfNeeded()
        self.verticalCollectionView.reloadData()
        self.verticalCollectionViewHeightConstraints.constant = self.verticalCollectionView.contentSize.height

    }
}

extension VerticalCollectionviewItemTableViewCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
            let item = self.vc!.explorePostArray[indexPath.row]
            let userItem = self.vc!.explorePostArray[indexPath.row].userData
            var mediaSet = [String]()
            if (item.mediaSet!.count) > 1{
                item.mediaSet?.forEach({ (it) in
                    mediaSet.append(it.file ?? "")
                })
            }
            log.verbose("MediaSet = \(mediaSet)")
            let vc = R.storyboard.post.showPostVC()
            let objectToSend = ShowUserProfileData(fname: userItem?.fname, lname: userItem?.lname, username: userItem?.username, aboutMe: userItem?.about, followersCount: 0, followingCount: 0, postCount: userItem?.posts, isFollowing: false, userId: userItem?.userID,imageString: userItem?.avatar,timeText: item.timeText,isAdmin: userItem?.admin)
            let object = ShowPostModel(userId: item.userID, imageString: item.avatar, username: item.username, type: item.type, timeText: item.timeText, MediaURL: item.mediaSet![0].file, likesCount: item.likes, commentCount: item.comments?.count, isLiked: item.isLiked, isSaved: item.isSaved, showUserProfile: objectToSend,mediaCount:item.mediaSet?.count,postId: item.postID,description: item.datumDescription,youtube: item.youtube,MediaUrlsArray:mediaSet)
            vc!.object = object
            
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
}

extension VerticalCollectionviewItemTableViewCell: TRMosaicLayoutDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.vc!.explorePostArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.currentIndexPath = indexPath
        let item = self.vc!.explorePostArray[indexPath.row]
        
        if item.type == "video" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID", for: indexPath) as! PPMosaicVideoItemCollectionViewCell
            cell.bind(item: item)
            return cell
        }else if item.type == "image" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
            cell.bind(item: item)
            return cell
        }else if item.type == "gif" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID", for: indexPath) as! PPMosaicGIFItemCollectionViewCell
            cell.bind(item: item,indexPath: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
        cell.bind(item: item)
        return cell
    }
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 150
    }
   
}
