//
//  PPPostItemViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 11/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPPostItemViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var viewModel : PostItemViewModeling?
    
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
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
    
    func setupRx(){
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                self.viewModel?.isInitialize.accept(true)
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.reloadDataTrig.asDriver()
            .filter({$0})
            .drive(onNext : { value in
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.selectUserItem.asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.showUserProfile(userID: value!)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.sharePost
            .asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.sharePost(item: value!)
            }).disposed(by: self.disposeBag)
        
//        self.viewModel?.getComment
//            .asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                SwinjectStoryboard.defaultContainer.assembleComments(item: (value!))
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPCommentViewControllerID") as! PPCommentViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
//        self.viewModel?.getLikesFromPostItem
//            .asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                SwinjectStoryboard.defaultContainer.assembleLikesPage(postID: (value?.post_id)!)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPLikesPageViewControllerID") as! PPLikesPageViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
        self.viewModel?.goBack
            .asDriver()
            .filter({$0})
            .drive(onNext : { value in
                self.navigationController?.popViewController(animated: true)
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

extension PPPostItemViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel?.item.value == nil {
            return 0
        }
        return (self.viewModel?.item.value!.comments?.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //self.contentIndexPath = indexPath
        
        if indexPath.row == 0 {
            if self.viewModel?.item.value!.type == "video" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PPVideoItemTableViewCellID") as! PPVideoItemTableViewCell
//                cell.bind(item: (self.viewModel?.item.value!)!, viewModel: self.viewModel!)
                return cell
            }else if self.viewModel!.item.value!.type == "image" {
                
                if (self.viewModel!.item.value!.media_set?.count)! > 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PPMultiImageItemTableViewCellID") as! PPMultiImageItemTableViewCell
//                    cell.bind(item: (self.viewModel?.item.value!)!, viewModel: self.viewModel!)
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PPImageItemTableViewCellID") as! PPImageItemTableViewCell
//                    cell.bind(item: (self.viewModel?.item.value!)!, viewModel: self.viewModel!)
                    return cell
                }
                
            }else if self.viewModel!.item.value!.type! == "gif" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PPGIFItemTableViewCellID") as! PPGIFItemTableViewCell
//                cell.bind(item: (self.viewModel?.item.value!)!, viewModel: self.viewModel!)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPYoutubeItemTableViewCellID") as! PPYoutubeItemTableViewCell
//            cell.bind(item: (self.viewModel?.item.value!)!, viewModel: self.viewModel!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPCommentItemTableViewCellID") as! PPCommentItemTableViewCell
//        cell.bind(item: ((self.viewModel?.item.value!.comments![indexPath.row-1])!), viewModel: self.viewModel!)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

