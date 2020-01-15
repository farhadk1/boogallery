//
//  FavoritesVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class FavoritesVC: BaseVC {
    
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var contentCollectionView: UICollectionView!

    
    private var favoriteArray = [FavoriteModel.Datum]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    func setupUI(){
        
        self.title = "Favorites"
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
      
        self.contentCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicVideoItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID")
        self.contentCollectionView.register(UINib(nibName: "PPMosaicImageItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicImageItemCollectionViewCellID")
        
        
    }
  
    
    private func fetchFavorites(){
        if Connectivity.isConnectedToNetwork(){
            self.favoriteArray.removeAll()
            
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background({
                FavoriteManager.instance.fetchFavorites(accessToken: accessToken, limit: 10, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                self.favoriteArray = success?.data ?? []
                                if self.favoriteArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.contentCollectionView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.contentCollectionView.reloadData()
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                                log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

extension FavoritesVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    
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
        return self.favoriteArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.favoriteArray[indexPath.row]
        
        if item.type == "video" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicVideoItemCollectionViewCellID", for: indexPath) as! PPMosaicVideoItemCollectionViewCell
            cell.bindFavoritePost(item: item)
            return cell
        }else if item.type == "image" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
            cell.bindFavoritePost(item: item)
            return cell
        }else if item.type == "gif" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID", for: indexPath) as! PPMosaicGIFItemCollectionViewCell
            
            cell.bindfavoritePost(item: item, indexPath: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicImageItemCollectionViewCellID", for: indexPath) as! PPMosaicImageItemCollectionViewCell
        cell.bindFavoritePost(item: item)
        return cell
        
        
    }
    
}
