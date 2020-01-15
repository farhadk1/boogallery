//
//  PPFollowerFollowingViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 11/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import PixelPhotoFramework

class PPFollowerFollowingViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var viewModel : FollowerFollowingViewModeling?
    var disposeBag = DisposeBag()
    
    var alreadyInitialize = false
    var contentIndexPath : IndexPath?
    
    var onUserSelects: (([UserModel]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.onUserSelects?((self.viewModel?.userSelect)!)
    }
    
    func setupRx(){
        
        if viewModel?.type == PROFILEMODE.FOLLOWER {
            self.title = "Follower"
        }else{
            self.title = "Following"
        }
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPProfileCheckBoxItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPProfileCheckBoxItemTableViewCellID")
        
        self.contentTblView.es.addPullToRefresh {
            [unowned self] in
            self.viewModel!.state.accept(DATASTATUS.PULLTOREFRESH)
        }
        
        self.contentTblView.es.addInfiniteScrolling {
            [unowned self] in
            self.viewModel?.state.accept(DATASTATUS.LOADMORE)
        }
        
        self.viewModel?.state.accept(DATASTATUS.INITIAL)
    }
    
    func setupView(){
        
        self.viewModel?.selectUserItem.asDriver()
            .filter({$0 != nil})
            .distinctUntilChanged()
            .drive(onNext : { value in
                self.showUserProfile(userID: value!)
            }).disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { _ in
                print(self.alreadyInitialize)
                if !self.alreadyInitialize {
                    self.alreadyInitialize = true
                    self.viewModel?.isInitialize.accept(true)
                }
                self.viewModel!.selectUserItem.accept(nil)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.userList
            .asDriver(onErrorJustReturn: [])
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
//        self.viewModel?.finishedInfiniteScroll
//            .asDriver()
//            .drive(onNext : { _ in
//                self.contentTblView.reloadData()
//                self.contentTblView.es.stopLoadingMore()
//                
//                if (self.contentIndexPath != nil) {
//                    self.contentTblView.scrollToRow(at: self.contentIndexPath!, at: UITableView.ScrollPosition.bottom, animated: true)
//                }
//            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedPullToRefresh
            .asDriver()
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
                self.contentTblView.es.stopPullToRefresh()
                self.contentTblView.es.resetNoMoreData()
            }).disposed(by: self.disposeBag)
    }
    
    
}


extension PPFollowerFollowingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.userList.value.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.contentIndexPath = indexPath
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPProfileCheckBoxItemTableViewCellID") as! PPProfileCheckBoxItemTableViewCell
//        cell.bind(item: (self.viewModel?.userList.value[indexPath.row])!, viewModel: self.viewModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PPProfileCheckBoxItemTableViewCell else {
            return
        }
        
        let item = (self.viewModel?.userList.value[indexPath.row])!
        
        if self.viewModel?.type != PROFILEMODE.CHAT {
            if self.viewModel!.type == PROFILEMODE.MENTIONEDFOLLOWER {
                let userSelectedCount = self.viewModel!.userSelect.filter({$0.user_id == item.user_id})
                
                if userSelectedCount.count == 0 {
                    cell.checkBox.on = true
                    self.viewModel?.userSelect.append(item)
                }else{
                    var tempArr = self.viewModel?.userSelect
                    tempArr!.remove(at: (tempArr?.index(where:{$0.user_id! == item.user_id!}))!)
                    self.viewModel?.userSelect = tempArr!
                    cell.checkBox.on = false
                }
            }else{
                self.viewModel?.selectUserItem.accept(item.user_id!)
            }
            
            
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }else{
//            SwinjectStoryboard.defaultContainer.assembleChatItem(user: item)
//            let sb = SwinjectStoryboard.create(name: "Chat",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let nextVC = sb.instantiateViewController(withIdentifier: "PPChatViewControllerID") as! PPChatViewController
//            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}
