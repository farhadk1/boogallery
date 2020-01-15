//
//  SearchVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import RxSwift
import RxCocoa
import Async
import PixelPhotoSDK

class SearchVC: BaseVC {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var hashTagView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var hashTagIndicatorVIew: UIView!
    @IBOutlet weak var usersIndicatorView: UIView!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var hashTagLbl: UILabel!
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel : SearchViewModeling?
    var searchArray:SearchModel.DataClass?
    var searchType:String? = ""
    
    @IBOutlet weak var usersLbl: UILabel!
    @IBOutlet weak var hashTagsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.search(KeyWord: "a")
    }
    
    func setupUI(){
        self.searchBar.sizeToFit()
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        self.title = NSLocalizedString("Search", comment: "")
        self.userLbl.text = NSLocalizedString("USERS", comment: "")
        self.hashTagLbl.text = NSLocalizedString("HASHTAGS", comment: "")
        
        self.contentTblView.register(UINib(nibName: "PPNoResultTableViewCell", bundle: nil), forCellReuseIdentifier: "PPNoResultTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPProfileCheckBoxItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPProfileCheckBoxItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPHashTagItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPHashTagItemTableViewCellID")
        
        self.hashTagIndicatorVIew.backgroundColor = UIColor.white
        self.usersIndicatorView.backgroundColor = UIColor.mainColor
        self.searchType = "user"
        
        let userTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userViewTapped(tapGestureRecognizer:)))
        userView.isUserInteractionEnabled = true
        userView.addGestureRecognizer(userTapGestureRecognizer)
        
        let hashTagTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hashtagViewTapped(tapGestureRecognizer:)))
        hashTagView.isUserInteractionEnabled = true
        hashTagView.addGestureRecognizer(hashTagTapGestureRecognizer)
    }
    @objc func userViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.hashTagIndicatorVIew.backgroundColor = UIColor.lightGray
        self.usersIndicatorView.backgroundColor = UIColor.mainColor
        self.searchType = "user"
        self.search(KeyWord: "a")
    }
    @objc func hashtagViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.hashTagIndicatorVIew.backgroundColor = UIColor.mainColor
        self.usersIndicatorView.backgroundColor = UIColor.lightGray
        self.searchType = "hashTag"
        self.search(KeyWord: "a")
        
    }
  
     func search(KeyWord:String){
        if Connectivity.isConnectedToNetwork(){
             self.searchArray?.users?.removeAll()
            self.searchArray?.hash?.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                SearchManager.instance.search(accessToken: accessToken, limit: 10, offset: 0, tagOffset: 0, keyword: KeyWord, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? nil)")
                                self.searchArray = success?.data ?? nil
                                if (self.searchArray?.users!.isEmpty)!{
                                    self.searchType = "empty"
                                    self.contentTblView.reloadData()
                                }else{
                                    if self.searchType == "user"{
                                        self.contentTblView.reloadData()
                                    }else if self.searchType == "hashTag"{
                                        self.contentTblView.reloadData()
                                        
                                    }
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

extension SearchVC : UISearchBarDelegate {
    
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(KeyWord: searchBar.text!)
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()


    }
    
}

extension SearchVC : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchType == "user"{
            return ((self.searchArray?.users!.count) ?? 0)
        }else if searchType == "hashTag" {
            return ((self.searchArray?.hash!.count) ?? 0)
            
        }else{
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchType == "user"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPProfileCheckBoxItemTableViewCellID") as! PPProfileCheckBoxItemTableViewCell
            let object = self.searchArray?.users![indexPath.row]
            cell.vcSearch = self
            cell.userId = object?.userID ?? 0
            cell.profileNameLbl.text = object?.username ?? ""
            cell.userNameLbl.text = "Last seen \(object?.timeText ?? "")"
            let url = URL.init(string:object?.avatar ?? "")
            cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
            if (object?.isFollowing?.intValue == 1){
                cell.followBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
                cell.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                cell.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                
            }else{
                cell.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                cell.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                cell.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
            }
            if (object?.isFollowing?.BoolValue) ?? false{
                cell.followBtn.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
                cell.followBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                cell.followBtn.setTitle(NSLocalizedString("Following", comment: ""), for: UIControl.State.normal)
                
            }else{
                cell.followBtn.applyGradient(colours: [UIColor.white , UIColor.white], start:  CGPoint(x: 0.0, y: 1.0), end:  CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.mainColor)
                cell.followBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
                cell.followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: UIControl.State.normal)
            }
            
            
            return cell
        }else if searchType == "hashTag" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPHashTagItemTableViewCellID") as! PPHashTagItemTableViewCell
            let object = self.searchArray?.hash![indexPath.row]
            cell.hashLbl.text = "\(object?.tag ?? "")"
            cell.numHashLbl.text = "\(object?.useNum  ?? 0) \(NSLocalizedString("Post", comment: ""))"
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPNoResultTableViewCellID") as! PPNoResultTableViewCell
            return cell
        }
    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            if searchType == "user"{
                let vc = R.storyboard.post.showUserProfileVC()

                let object = self.searchArray?.users![indexPath.row]
                let objectToSend = ShowUserProfileData(fname: object?.fname, lname: object?.lname, username: object?.username, aboutMe: object?.about, followersCount: object?.followers, followingCount: object?.following, postCount: object?.posts, isFollowing: object?.isFollowing?.BoolValue, userId: object?.userID,imageString: object?.avatar,timeText: object?.timeText,isAdmin: object?.admin)
                vc!.object = objectToSend
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }else if searchType == "hashTag" {
              let vc = R.storyboard.search.fetchHashTagPostVC()
                vc?.hashString = self.searchArray?.hash![indexPath.row].tag ?? ""
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.viewModel?.userItems.value.count == 0 {
            return tableView.frame.height
        }
        return UITableView.automaticDimension
    }
    
    
}
