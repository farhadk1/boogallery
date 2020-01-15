//
//  GIFVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 11/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Async
import PixelPhotoSDK

class GIFVC: BaseVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    var viewModel : SelectGIFViewModeling?
    var disposeBag = DisposeBag()
    private var gifArray = [GIFModel.Datum]()
    
    var contentIndexPath : IndexPath?
    var delegate:didSelectGIFDelegate?
    
//    var onClickedItem: ((GiphyItem) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.fetchGIFS()
    }
    
    func setupUI(){
        self.title = NSLocalizedString("Select GIF", comment: "")
        self.searchBar.delegate = self
        self.contentCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
    }
    private func fetchGIFS(){
        if Connectivity.isConnectedToNetwork(){
            self.gifArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            Async.background({
                GIFManager.instance.getGIFS(limit: 10, offset: 1, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                self.gifArray = success?.data ?? []
                                self.contentCollectionView.reloadData()
                                
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
extension GIFVC : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
}

extension GIFVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return self.gifArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.contentIndexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID", for: indexPath) as! PPMosaicGIFItemCollectionViewCell
        
        cell.bindGif(item: self.gifArray[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 , height: 150)
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
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
            self.delegate?.didSelectGIF(GIFUrl: self.gifArray[indexPath.row].images?.fixedHeightStill?.url ?? "")
            self.navigationController?.popViewController(animated: true)
            
        }
}

