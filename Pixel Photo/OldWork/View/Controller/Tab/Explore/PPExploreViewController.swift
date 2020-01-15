//
//  PPExploreViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

class PPExploreViewController: PPBaseViewController {
    
    var disposeBag = DisposeBag()
    
    var viewModel : ExploreViewModeling?
    var alreadyInitialize = false
    
    var currentIndexPath : CGFloat?
    
    @IBOutlet weak var contentTblView: UITableView!
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        _ = NotificationCenter.default.rx
        //            .notification(Notification.Name(rawValue: "update_data"))
        //            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
        //            .subscribe(onNext: { notification in
        //                self.alreadyInitialize = false
        //            })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        self.navigationController?.isNavigationBarHidden = false
        
//        searchBar.delegate = self
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.es.addPullToRefresh {
            [unowned self] in
            self.viewModel!.state.accept(DATASTATUS.PULLTOREFRESH)
        }
        
        self.contentTblView.es.addInfiniteScrolling {
            [unowned self] in
            self.viewModel?.state.accept(DATASTATUS.LOADMORE)
        }
        
        self.contentTblView.register(UINib(nibName: "PPHorizontalCollectionviewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPHorizontalCollectionviewItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "VerticalCollectionviewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "VerticalCollectionviewItemTableViewCellID")
        
    }
    
    func setupRx(){
        
        self.viewModel?.selectUserItem.asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.showUserProfile(userID: value!)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedInfiniteScroll
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.contentTblView.es.stopLoadingMore()
                self.reloadDataAndView()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedPullToRefresh
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.contentTblView.es.stopPullToRefresh()
                self.contentTblView.es.resetNoMoreData()
                self.reloadDataAndView()
            }).disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext : { value in
                if !self.alreadyInitialize {
                    self.alreadyInitialize = true
                    self.viewModel?.isInitialize.accept(true)
                }
                self.viewModel?.selectUserItem.accept(nil)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.userList
            .asDriver()
            .filter({_ in self.alreadyInitialize})
            .drive(onNext : { value in
                self.alreadyInitialize = true
                self.reloadDataAndView()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.exploreItems
            .asDriver()
            .filter({_ in self.alreadyInitialize})
            .drive(onNext : { value in
                self.alreadyInitialize = true
                self.reloadDataAndView()
            }).disposed(by: self.disposeBag)
        
//        self.viewModel?.showPost
//            .asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                SwinjectStoryboard.defaultContainer.assemblePostItem(item: (self.viewModel?.showPost)!)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPPostItemViewControllerID") as! PPPostItemViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
    }
    
    func reloadDataAndView(){
        let contentOffset = self.contentTblView.contentOffset
        self.contentTblView.reloadData()
        self.contentTblView.layoutIfNeeded()
        self.contentTblView.setContentOffset(contentOffset, animated: false)
    }
    
}
//extension PPExploreViewController : UISearchBarDelegate {
//    
//    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        SwinjectStoryboard.defaultContainer.assembleSearch()
//        let sb = SwinjectStoryboard.create(name: "Search",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let nextVC = sb.instantiateViewController(withIdentifier: "SearchViewControllerID") as! SearchViewController
//        nextVC.navigationItem.hidesBackButton = true
//        self.navigationController?.pushViewController(nextVC, animated: true)
//        return false
//    }
//    


extension PPExploreViewController : UITableViewDataSource , UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndexPath = scrollView.contentOffset.y
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPHorizontalCollectionviewItemTableViewCellID") as! PPHorizontalCollectionviewItemTableViewCell
//            cell.bind(viewModel: self.viewModel!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerticalCollectionviewItemTableViewCellID") as! VerticalCollectionviewItemTableViewCell
        cell.bind(viewModel: self.viewModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 175
        }
        return UITableView.automaticDimension
    }
    
}

