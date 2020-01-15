//
//  PPLikesPageViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PPLikesPageViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var disposeBag = DisposeBag()
    
    var viewModel : LikesViewModeling?
    var alreadyInitialize = false
    var contentIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPProfileCheckBoxItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPProfileCheckBoxItemTableViewCellID")
    }
    
    func setupRx(){
        
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                if !self.alreadyInitialize {
                    self.alreadyInitialize = true
                    self.viewModel?.isInitialize.accept(true)
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.selectUserItem
            .asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.showUserProfile(userID: value!)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedInfiniteScroll
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
                self.contentTblView.es.stopLoadingMore()
                
                if (self.contentIndexPath != nil) {
                    self.contentTblView.scrollToRow(at: self.contentIndexPath!, at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedPullToRefresh
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
                self.contentTblView.es.stopPullToRefresh()
                self.contentTblView.es.resetNoMoreData()
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

extension PPLikesPageViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.userList.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPProfileCheckBoxItemTableViewCellID") as! PPProfileCheckBoxItemTableViewCell
//        cell.bind(item: (self.viewModel?.userList[indexPath.row])!, viewModel: self.viewModel!)
        return cell
    }
    
    
}
