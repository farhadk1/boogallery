//
//  PPSelectGIFViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 10/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

class PPSelectGIFViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    var viewModel : SelectGIFViewModeling?
    var disposeBag = DisposeBag()
    
    var contentIndexPath : IndexPath?
    
    var onClickedItem: ((GiphyItem) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.title = NSLocalizedString("Select GIF", comment: "")
        
        self.searchBar.delegate = self
        
        self.contentCollectionView.dataSource = self
        self.contentCollectionView.delegate = self
        
        self.contentCollectionView.register(UINib(nibName: "PPMosaicGIFItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID")
    }
    
    func setupRx(){
        self.searchBar
            .rx.text
            .orEmpty
            .subscribe(onNext: { [unowned self] query in
                self.viewModel?.queryString.accept(query)
            }).disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { _ in
                self.viewModel?.isInitialize.accept(true)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.gifList
            .asDriver(onErrorJustReturn: [])
            .drive(onNext : { _ in
                self.contentCollectionView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedInfiniteScroll
            .asDriver()
            .drive(onNext : { _ in
                self.contentCollectionView.finishInfiniteScroll()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedPullToRefresh
            .asDriver()
            .drive(onNext : { _ in
                self.contentCollectionView.finishInfiniteScroll()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.isSearching
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext : { arg in
                if arg {
                    self.contentCollectionView.es.addPullToRefresh {
                        [unowned self] in
                        self.viewModel!.state.accept(DATASTATUS.PULLTOREFRESH)
                    }
                    
                    self.contentCollectionView.es.addInfiniteScrolling {
                        [unowned self] in
                        self.viewModel?.state.accept(DATASTATUS.LOADMORE)
                    }
                    
                }else{
                    self.contentCollectionView.es.removeRefreshFooter()
                    self.contentCollectionView.es.removeRefreshHeader()
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.searchGifList
            .asDriver()
            .drive(onNext : { _ in
                self.contentCollectionView.reloadData()
            }).disposed(by: self.disposeBag)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension PPSelectGIFViewController : UISearchBarDelegate {
    
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

extension PPSelectGIFViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if (self.viewModel?.isSearching.value)! {
            return (self.viewModel?.searchGifList.value.count)!
        }
        return (self.viewModel?.gifList.value.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.contentIndexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPMosaicGIFItemCollectionViewCellID", for: indexPath) as! PPMosaicGIFItemCollectionViewCell
        
        if (self.viewModel?.isSearching.value)! {
            cell.bind(item: (self.viewModel?.searchGifList.value[indexPath.row])!, indexPath: indexPath)
        }else{
            cell.bind(item: (self.viewModel?.gifList.value[indexPath.row])!, indexPath: indexPath)
        }
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
        
        if (self.viewModel?.isSearching.value)! {
            self.onClickedItem!((self.viewModel?.searchGifList.value[indexPath.row])!)
        }else{
            self.onClickedItem!((self.viewModel?.gifList.value[indexPath.row])!)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
