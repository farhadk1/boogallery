//
//  CommentVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import RxSwift
import RxCocoa
import Async
import PixelPhotoSDK

class CommentVC: BaseVC {
    
    var viewModel : CommentViewModeling?
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var messageTxtViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
    var alreadyInitialize = false
    private var postCommentArray = [CommentModel.Datum]()
    private var refreshControl = UIRefreshControl()
    var contentIndexPath : IndexPath?
    var postId:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.fetchComments()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI(){
        self.title = "Comments"
        self.messageTxtView.delegate = self
        self.messageTxtView.layer.cornerRadius = 10
        self.messageTxtView.layer.borderColor = UIColor.lightGray.cgColor
        self.messageTxtView.layer.borderWidth = 1.0
        self.sendBtn.isCircular()
        self.adjustHeight()
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        contentTblView.addSubview(refreshControl)
        
        self.contentTblView.register(UINib(nibName: "PPCommentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPCommentItemTableViewCellID")
    }
    @objc func refresh(sender:AnyObject) {
        self.postCommentArray.removeAll()
        self.contentTblView.reloadData()
        self.fetchComments()
        refreshControl.endRefreshing()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.addComment()
        self.messageTxtView.text = ""

        
    }
    
    //    func setupRx(){
    //
    //        self.messageTxtView.rx.text.orEmpty.bind(to: (viewModel?.commentText)!).disposed(by: self.disposeBag)
    //
    //        self.rx.viewDidAppear
    //            .asDriver()
    //            .drive(onNext : { value in
    //                if !self.alreadyInitialize {
    //                    self.alreadyInitialize = true
    //                    self.viewModel?.isInitialize.accept(true)
    //                }
    //            }).disposed(by: self.disposeBag)
    //
    //        self.viewModel?.commentText
    //            .asDriver(onErrorJustReturn: "")
    //            .drive(onNext : { value in
    //                if value == "" {
    //                    self.messageTxtView.text = ""
    //                    self.adjustHeight()
    //                }
    //            }).disposed(by:self.disposeBag)
    //
    //        self.viewModel?.reloadData
    //            .asDriver(onErrorJustReturn: false)
    //            .drive(onNext : { _ in
    //                self.contentTblView.reloadData()
    //            }).disposed(by: self.disposeBag)
    //
    //        self.sendBtn.rx.tap
    //            .throttle(0.3, scheduler: MainScheduler.instance)
    //            .subscribe({ _ in
    //                self.viewModel?.sendCommentTrigger.accept(true)
    //            }).disposed(by:self.disposeBag)
    //
    //        self.viewModel?.finishedInfiniteScroll
    //            .asDriver()
    //            .filter({$0})
    //            .drive(onNext : { _ in
    //                self.reload()
    //            }).disposed(by: self.disposeBag)
    //
    //        self.viewModel?.selectUserItem.asDriver()
    //            .filter({$0 != nil})
    //            .drive(onNext : { value in
    //                self.showUserProfile(userID: value!)
    //            }).disposed(by: self.disposeBag)
    //
    //        self.viewModel?.finishedPullToRefresh
    //            .asDriver()
    //            .filter({$0})
    //            .drive(onNext : { _ in
    //                self.contentTblView.reloadData()
    //                self.contentTblView.es.stopPullToRefresh()
    //                self.contentTblView.es.resetNoMoreData()
    //            }).disposed(by: self.disposeBag)
    //
    //    }
    
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
    
    private func addComment(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postID = postId ?? 0
            let text = self.messageTxtView.text ?? ""
            Async.background({
                CommentManager.instance.addComment(accessToken: accessToken, postId: postID, Text: text
                    , completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    
                                    log.debug("userList = \(success?.status ?? "")")
                                    self.fetchComments()
                                    
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
    private func fetchComments(){
        if Connectivity.isConnectedToNetwork(){
            self.postCommentArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let postID = postId ?? 0
            Async.background({
                CommentManager.instance.getComment(accessToken: accessToken, postId: postID, limit: 10, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                self.postCommentArray = success?.data ?? []
                                if self.postCommentArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.contentTblView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.contentTblView.reloadData()
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

extension CommentVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
    }
}

extension CommentVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.postCommentArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPCommentItemTableViewCellID") as! PPCommentItemTableViewCell
        let object = self.postCommentArray[indexPath.row]
        cell.vc = self
        cell.bind(item:object , viewModel: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
