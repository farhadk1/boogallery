//
//  PPCommentViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 09/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPCommentViewController: PPBaseViewController {
    
    var viewModel : CommentViewModeling?
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var messageTxtViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    
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
        
        self.messageTxtView.delegate = self
        self.messageTxtView.layer.cornerRadius = 10
        self.messageTxtView.layer.borderColor = UIColor.lightGray.cgColor
        self.messageTxtView.layer.borderWidth = 1.0
        
        self.sendBtn.isCircular()
        
        self.adjustHeight()
        
        self.contentTblView.es.addPullToRefresh {
            [unowned self] in
            self.viewModel!.state.accept(DATASTATUS.PULLTOREFRESH)
        }
        
        //        self.contentTblView.es.addInfiniteScrolling {
        //            [unowned self] in
        //            self.viewModel?.state.accept(DATASTATUS.LOADMORE)
        //        }
        
        self.contentTblView.register(UINib(nibName: "PPCommentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPCommentItemTableViewCellID")
    }
    
    func setupRx(){
        
        self.messageTxtView.rx.text.orEmpty.bind(to: (viewModel?.commentText)!).disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                if !self.alreadyInitialize {
                    self.alreadyInitialize = true
                    self.viewModel?.isInitialize.accept(true)
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.commentText
            .asDriver(onErrorJustReturn: "")
            .drive(onNext : { value in
                if value == "" {
                    self.messageTxtView.text = ""
                    self.adjustHeight()
                }
            }).disposed(by:self.disposeBag)
        
        self.viewModel?.reloadData
            .asDriver(onErrorJustReturn: false)
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.sendBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.viewModel?.sendCommentTrigger.accept(true)
            }).disposed(by:self.disposeBag)
        
        self.viewModel?.finishedInfiniteScroll
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.reload()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.selectUserItem.asDriver()
            .filter({$0 != nil})
            .drive(onNext : { value in
                self.showUserProfile(userID: value!)
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
    
    func reload(){
        self.contentTblView.reloadData()
        self.contentTblView.es.stopLoadingMore()
        
        if (self.contentIndexPath != nil) {
            self.contentTblView.scrollToRow(at: self.contentIndexPath!, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    func adjustHeight(){
        let size = self.messageTxtView.sizeThatFits(CGSize(width: self.messageTxtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        messageTxtViewHeightConstraints.constant = size.height
        self.viewDidLayoutSubviews()
        self.messageTxtView.setContentOffset(CGPoint.zero, animated: false)
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

extension PPCommentViewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
    }
}

extension PPCommentViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.commentItems.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPCommentItemTableViewCellID") as! PPCommentItemTableViewCell
//        cell.bind(item: (self.viewModel?.commentItems[indexPath.row])!, viewModel: self.viewModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
