//
//  SearchViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 08/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: PPBaseViewController {
    
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
    
    @IBOutlet weak var usersLbl: UILabel!
    @IBOutlet weak var hashTagsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        self.searchBar.sizeToFit()
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        
        self.title = NSLocalizedString("Search", comment: "")
        
        self.userLbl.text = NSLocalizedString("USERS", comment: "")
        self.hashTagLbl.text = NSLocalizedString("HASHTAGS", comment: "")
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPNoResultTableViewCell", bundle: nil), forCellReuseIdentifier: "PPNoResultTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPProfileCheckBoxItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPProfileCheckBoxItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPHashTagItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPHashTagItemTableViewCellID")
        
        self.hashTagIndicatorVIew.backgroundColor = UIColor.white
        self.usersIndicatorView.backgroundColor = UIColor.mainColor
    }
    
    func setupRx(){
        
        //self.searchBar.rx.text.orEmpty.bind(to: (viewModel?.searchHashTagText)!).disposed(by: self.disposeBag)
        
        self.searchBar
            .rx
            .text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                self.viewModel?.searchHashTagText.accept(query)
            }).disposed(by: self.disposeBag)
        
        
        
        self.hashTagLbl.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                self.hashTagIndicatorVIew.backgroundColor = UIColor.mainColor
                self.usersIndicatorView.backgroundColor = UIColor.lightGray
                self.viewModel?.mode.accept(SEARCHMODE.HASHTAG)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.searchRandom
            .asDriver(onErrorJustReturn: false)
            .filter({$0})
            .drive(onNext : { value in
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.userLbl.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                self.hashTagIndicatorVIew.backgroundColor = UIColor.lightGray
                self.usersIndicatorView.backgroundColor = UIColor.mainColor
                self.viewModel?.mode.accept(SEARCHMODE.USER)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.mode
            .asDriver(onErrorJustReturn: SEARCHMODE.NONE)
            .drive(onNext : { value in
                if value == SEARCHMODE.NONE {
                    self.contentTblView.allowsSelection = false
                }else{
                    self.contentTblView.allowsSelection = true
                }
                
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.userItems
            .asDriver()
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
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

extension SearchViewController : UISearchBarDelegate {
    
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

extension SearchViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.viewModel?.userItems.value.count == 0  {
            return 1
        }
        
        if self.viewModel?.mode.value == SEARCHMODE.USER {
            return (self.viewModel?.userItems.value.count)!
        }
        
        return (self.viewModel?.hashItems.value.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.viewModel?.userItems.value.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPNoResultTableViewCellID") as! PPNoResultTableViewCell
//            cell.bind(viewModel: self.viewModel!)
            return cell
        }
        
        if self.viewModel?.mode.value == SEARCHMODE.USER {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPProfileCheckBoxItemTableViewCellID") as! PPProfileCheckBoxItemTableViewCell
//            cell.bind(item: (self.viewModel?.userItems.value[indexPath.row])!, viewModel: self.viewModel!)
            return cell
        }else if self.viewModel?.mode.value == SEARCHMODE.HASHTAG {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPHashTagItemTableViewCellID") as! PPHashTagItemTableViewCell
//            cell.bind(hashItem: (self.viewModel?.hashItems.value[indexPath.row])!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPNoResultTableViewCellID") as! PPNoResultTableViewCell
//        cell.bind(viewModel: self.viewModel!)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.viewModel?.userItems.value.count != 0 {
            if self.viewModel?.mode.value == SEARCHMODE.HASHTAG {

            }else if self.viewModel?.mode.value == SEARCHMODE.USER {
                self.showUserProfile(userID: (self.viewModel?.userItems.value[indexPath.row])!.user_id!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.viewModel?.userItems.value.count == 0 {
            return tableView.frame.height
        }
        return UITableView.automaticDimension
    }
    
    
}
