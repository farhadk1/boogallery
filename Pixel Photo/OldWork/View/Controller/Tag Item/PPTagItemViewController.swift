//
//  PPTagItemViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 06/03/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPTagItemViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var viewModel : HashTagItemViewModeling?
    
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
    }
    
    func setupRx(){
//        self.viewModel?.showPost
//            .asDriver()
//            .filter({$0 != nil})
//            .drive(onNext : { value in
//                SwinjectStoryboard.defaultContainer.assemblePostItem(item: value!)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPPostItemViewControllerID") as! PPPostItemViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
        self.viewModel?.sharePost
            .asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.sharePost(item: value!)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.getComment.asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.getCommentFromPostID(item: value!)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.selectUserItem.asDriver()
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
        
//        self.viewModel?.searchHashtag
//            .asDriver()
//            .filter({$0.count != 0})
//            .drive(onNext : { items in
//                SwinjectStoryboard.defaultContainer.assembleHashTagPost(items: items)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPTagItemViewControllerID") as! PPTagItemViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
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
extension PPTagItemViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.viewModel?.items?.count == 0 { return 0 }
        return self.viewModel!.items!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.viewModel?.items![indexPath.row]
        
        if item?.type == "video" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPVideoItemTableViewCellID") as! PPVideoItemTableViewCell
//            cell.bind(item: item!,viewModel: self.viewModel!)
            return cell
        }else if item?.type == "image" {
            
            if (item?.media_set?.count)! > 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PPMultiImageItemTableViewCellID") as! PPMultiImageItemTableViewCell
//                cell.bind(item: item!,viewModel: self.viewModel!)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PPImageItemTableViewCellID") as! PPImageItemTableViewCell
//                cell.bind(item: item!, viewModel: self.viewModel!)
                return cell
            }
            
        }else if item?.type == "gif" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPGIFItemTableViewCellID") as! PPGIFItemTableViewCell
//            cell.bind(item: item!, viewModel: self.viewModel!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPYoutubeItemTableViewCellID") as! PPYoutubeItemTableViewCell
//        cell.bind(item: item!, viewModel: self.viewModel!)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
