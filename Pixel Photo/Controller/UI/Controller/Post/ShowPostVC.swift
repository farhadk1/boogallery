//
//  ShowPostVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 05/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoSDK

class ShowPostVC: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var viewModel : PostItemViewModeling?
    
    var disposeBag = DisposeBag()
    var object:ShowPostModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    func setupUI(){
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPYoutubeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPYoutubeItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPMultiImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPMultiImageItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPLinkItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPLinkItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPVideoItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPVideoItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPGIFItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPGIFItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPImageItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPCollectionViewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPCollectionViewItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPCommentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPCommentItemTableViewCellID")
    }
    
//    func setupRx(){
//
//        self.rx.viewDidAppear
//            .asDriver()
//            .drive(onNext : { value in
//                self.viewModel?.isInitialize.accept(true)
//                self.contentTblView.reloadData()
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.reloadDataTrig.asDriver()
//            .filter({$0})
//            .drive(onNext : { value in
//                self.contentTblView.reloadData()
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.selectUserItem.asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                self.showUserProfile(userID: value!)
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.sharePost
//            .asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                self.sharePost(item: value!)
//            }).disposed(by: self.disposeBag)
//
//        //        self.viewModel?.getComment
//        //            .asDriver()
//        //            .filter({$0 != nil})
//        //            .drive(onNext : { value in
//        //                SwinjectStoryboard.defaultContainer.assembleComments(item: (value!))
//        //                let sb = SwinjectStoryboard.create(name: "Post",
//        //                                                   bundle: nil,
//        //                                                   container: SwinjectStoryboard.defaultContainer)
//        //                let nextVC = sb.instantiateViewController(withIdentifier: "PPCommentViewControllerID") as! PPCommentViewController
//        //                self.navigationController?.pushViewController(nextVC, animated: true)
//        //            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.onErrorTrigger
//            .asDriver()
//            .filter({$0.0 != ""})
//            .drive(onNext : { arg in
//                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
//            }).disposed(by: self.disposeBag)
//
//        //        self.viewModel?.getLikesFromPostItem
//        //            .asDriver()
//        //            .filter({$0 != nil})
//        //            .drive(onNext : { value in
//        //                SwinjectStoryboard.defaultContainer.assembleLikesPage(postID: (value?.post_id)!)
//        //                let sb = SwinjectStoryboard.create(name: "Post",
//        //                                                   bundle: nil,
//        //                                                   container: SwinjectStoryboard.defaultContainer)
//        //                let nextVC = sb.instantiateViewController(withIdentifier: "PPLikesPageViewControllerID") as! PPLikesPageViewController
//        //                self.navigationController?.pushViewController(nextVC, animated: true)
//        //            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.goBack
//            .asDriver()
//            .filter({$0})
//            .drive(onNext : { value in
//                self.navigationController?.popViewController(animated: true)
//            }).disposed(by: self.disposeBag)
//
//    }
    
    
}

extension ShowPostVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.viewModel?.item.value == nil {
//            return 0
//        }
//        return (self.viewModel?.item.value!.comments?.count)! + 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //self.contentIndexPath = indexPath
        
        if indexPath.row == 0 {
            if self.object?.type == "video" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PPVideoItemTableViewCellID") as! PPVideoItemTableViewCell
                cell.bind(item: object!, viewModel: nil)
                cell.vc = self
                return cell
            }else if self.object?.type == "image" {
                
                if (self.object?.mediaCount ?? 0) > 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PPMultiImageItemTableViewCellID") as! PPMultiImageItemTableViewCell
                     cell.bind(item: object!, viewModel: nil)
                    cell.vc = self
                    cell.imageCollectionView.reloadData()
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PPImageItemTableViewCellID") as! PPImageItemTableViewCell
                   cell.bind(item: object!, viewModel: nil)
                    cell.vc = self
                    return cell
                }
                
            }else if self.object?.type == "gif" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PPGIFItemTableViewCellID") as! PPGIFItemTableViewCell
                cell.bind(item: object!, viewModel: nil)
                cell.vc = self
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPYoutubeItemTableViewCellID") as! PPYoutubeItemTableViewCell
            cell.bind(item: object!, viewModel: nil)
            cell.vc = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPImageItemTableViewCellID") as! PPImageItemTableViewCell
        cell.bind(item: object!, viewModel: nil)
        cell.vc = self
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

