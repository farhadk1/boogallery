//
//  PPNotificationViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

class PPNotificationViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    var disposeBag = DisposeBag()
    
    var viewModel : NotificationViewModeling?
    var contentIndexPath : IndexPath?
    var alreadyInitialize = false
    
    
    private lazy var chatBtn: UIButton = {
        let chatBtn = UIButton(type: .custom)
        chatBtn.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 10)
        chatBtn.setImage(UIImage(named:"ic_chat"), for: .normal)
        chatBtn.imageView?.contentMode = .scaleAspectFit
        return chatBtn
    }()
    
    private lazy var chatBtnItem : UIBarButtonItem = {
        let chatBtn = UIBarButtonItem(customView: self.chatBtn)
        return chatBtn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        self.navigationItem.title = "Notification"
        
        self.navigationController?.isNavigationBarHidden = false
        
        let chatBtnItem = UIBarButtonItem(customView: chatBtn)
        navigationItem.rightBarButtonItems = [chatBtnItem]
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPNotificationItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPNotificationItemTableViewCellID")
        
        
        self.contentTblView.es.addPullToRefresh { [unowned self] in
            self.viewModel!.state.accept(DATASTATUS.PULLTOREFRESH)
        }
        
        self.contentTblView.es.addInfiniteScrolling { [unowned self] in
            self.viewModel?.state.accept(DATASTATUS.LOADMORE)
        }
        
        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[3]
            tabItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }

    }
    
    func setupRx(){
        
        self.viewModel?.selectUserItem.asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.showUserProfile(userID: value!)
            }).disposed(by: self.disposeBag)
        
//        self.chatBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                SwinjectStoryboard.defaultContainer.assembleChatList()
//                let sb = SwinjectStoryboard.create(name: "Chat",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPChatListViewControllerID") as! PPChatListViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by:self.disposeBag)
        
//        self.viewModel?.showPost
//            .asDriver()
//            .filter({$0 != -1})
//            .drive(onNext : { value in
//
//                SwinjectStoryboard.defaultContainer.assemblePostItemByID(id: value)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPPostItemViewControllerID") as! PPPostItemViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
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
        
        self.rx.viewDidAppear
            .asDriver()
            .filter({_ in self.alreadyInitialize})
            .drive(onNext : { value in
                if self.alreadyInitialize {
                    self.alreadyInitialize = true
                    self.viewModel?.isInitialize.accept(true)
                }
                self.viewModel?.selectUserItem.accept(nil)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.messagesNum
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext : { value in
                if value == 0 {
                    self.chatBtnItem.removeBadge()
                }else{
                    self.chatBtnItem.addBadge(number: value!)
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.notificationNum
            .asDriver(onErrorJustReturn: 0)
            .filter({_ in self.alreadyInitialize})
            .drive(onNext : { value in
//                if let tabItems = self.tabBarController?.tabBar.items {
//                    if value == 0 {
//                        let tabItem = tabItems[3]
//                        tabItem.badgeValue = nil
//                    }else{
//                        let tabItem = tabItems[3]
//                        tabItem.badgeValue = "\(value!)"
//                    }
//                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.notificationList
            .asDriver()
            .drive(onNext : { value in
                self.alreadyInitialize = true
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
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

extension PPNotificationViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.notificationList.value.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPNotificationItemTableViewCellID") as! PPNotificationItemTableViewCell
//        cell.bind(item: (self.viewModel?.notificationList.value[indexPath.row])!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if self.viewModel?.notificationList.value[indexPath.row].type == "followed_u" {
           self.viewModel?.selectUserItem.accept(self.viewModel?.notificationList.value[indexPath.row].notifier_id)
        }else {
            print(self.viewModel!.notificationList.value[indexPath.row].post_id!)
            if let postID = self.viewModel!.notificationList.value[indexPath.row].post_id!.value as? String {
                self.viewModel?.showPost.accept(Int(postID)!)
            }else if let postIDInt = self.viewModel!.notificationList.value[indexPath.row].post_id!.value as? Int {
                self.viewModel?.showPost.accept(postIDInt)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
