//
//  PPSuggestionUserViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 27/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import UIScrollView_InfiniteScroll

class PPSuggestionUserViewController: UIViewController {
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    
    var disposeBag = DisposeBag()
    
    var viewModel : SuggestionUserViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupView()
        setupRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel?.state.accept(DATASTATUS.INITIAL)
    }
    
    func setupView(){
        
        self.title = NSLocalizedString("User Suggestion", comment: "")
        
        navigationItem.rightBarButtonItems = [doneBtn]
        
        self.contentCollectionView.dataSource = self
        self.contentCollectionView.delegate = self
        
        contentCollectionView.addInfiniteScroll { (tableView) -> Void in
            self.viewModel?.state.accept(DATASTATUS.LOADMORE)
        }
        
        self.contentCollectionView.register(UINib(nibName: "PPUserProfileThumbnailItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPUserProfileThumbnailItemCollectionViewCellID")
    }
    
    func setupRx(){
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { _ in
                self.viewModel?.getUserSuggestion.accept(true)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.userList
            .asDriver(onErrorJustReturn: [])
            .drive(onNext : { _ in
                self.contentCollectionView.reloadData()
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
        
        self.doneBtn.rx.tap
            .asDriver()
            .drive(onNext : { _ in
                let nextVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PPTabBarBaseViewControllerID") as! PPTabBarBaseViewController
                nextVC.navigationController?.isNavigationBarHidden = false
                self.present(nextVC, animated: true, completion: nil)
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

extension PPSuggestionUserViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return (self.viewModel?.userList.value.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPUserProfileThumbnailItemCollectionViewCellID", for: indexPath) as! PPUserProfileThumbnailItemCollectionViewCell
        cell.bind(viewModel: self.viewModel!, item: (self.viewModel?.userList.value[indexPath.row])!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 , height: 150)
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
    
    
}

