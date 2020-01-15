//
//  ExploreVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 03/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class ExploreVC: BaseVC {
    
    @IBOutlet weak var contentTblView: UITableView!
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    var currentIndexPath : CGFloat?
    var suggestedUsersArray = [SuggestedUserModel.Datum]()
    var explorePostArray = [ExplorePostModel.Datum]()
    var isDataLoading:Bool=false
    private var refreshControl = UIRefreshControl()
    
    var pageNo:Int=1
    var limit:Int=20
    var offset:Int=0 //pageNo*limit
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchUserSuggestions()
    }
    
    func setupUI(){
        self.navigationController?.isNavigationBarHidden = false
        
                searchBar.delegate = self
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
        self.contentTblView.register(UINib(nibName: "PPHorizontalCollectionviewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPHorizontalCollectionviewItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "VerticalCollectionviewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "VerticalCollectionviewItemTableViewCellID")
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        
    }
    @objc func refresh(sender:AnyObject) {
        self.limit = 30
        self.offset = 0
        self.suggestedUsersArray.removeAll()
        self.explorePostArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchUserSuggestions()
        refreshControl.endRefreshing()
        
    }
    func reloadDataAndView(){
        let contentOffset = self.contentTblView.contentOffset
        self.contentTblView.reloadData()
        self.contentTblView.layoutIfNeeded()
        self.contentTblView.setContentOffset(contentOffset, animated: false)
    }
    private func fetchUserSuggestions(){
        if appDelegate.isInternetConnected{
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                SuggestedUserManager.instance.getsuggestedUser(accessToken: accessToken, limit: 20, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.suggestedUsersArray = success?.data ?? []
                            self.contentTblView.reloadData()
                            self.fetchExplorePost(limit: self.limit)
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        })
                    }
                })
            })
        }else{
            log.error(InterNetError)
            self.view.makeToast(InterNetError)
        }
    }
    func fetchExplorePost(limit:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                ExplorePostManager.instance.explorePost(accessToken: accessToken, limit: limit, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.count ?? 0)")
                                self.explorePostArray = success?.data ?? []
                                self.contentTblView.reloadData()
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog { self.view.makeToast(sessionError?.errors?.errorText ?? "")
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
extension ExploreVC : UISearchBarDelegate {
   
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.tintColor = .white
        searchBar.resignFirstResponder()
        let vc = R.storyboard.search.searchVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}

extension ExploreVC : UITableViewDataSource , UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndexPath = scrollView.contentOffset.y
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPHorizontalCollectionviewItemTableViewCellID") as! PPHorizontalCollectionviewItemTableViewCell
            cell.vc = self
            cell.horizontalCollectionView.reloadData()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerticalCollectionviewItemTableViewCellID") as! VerticalCollectionviewItemTableViewCell
        cell.vc = self
        cell.layoutIfNeeded()
        cell.verticalCollectionView.reloadData()
        cell.verticalCollectionViewHeightConstraints.constant = cell.verticalCollectionView.contentSize.height
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 175
        }
        
        return UITableView.automaticDimension
    }
    
}

extension ExploreVC{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        print("scrollViewDidEndDragging")
        if ((contentTblView.contentOffset.y + contentTblView.frame.size.height) >= contentTblView.contentSize.height)
        {
            if !isDataLoading{
                isDataLoading = true
                self.pageNo=self.pageNo+1
                self.limit=self.limit+10
                self.offset=self.limit * self.pageNo
                self.fetchExplorePost(limit: limit)
                
            }
        }
    }
}
