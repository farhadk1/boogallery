//
//  CommentReplyVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 12/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import Async
import PixelPhotoSDK

class CommentReplyVC: BaseVC {
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLbel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    private var refreshControl = UIRefreshControl()
    private var replyCommentArray = [CommentreplyModel.Datum]()
    var contentIndexPath : IndexPath?
    var profileImageString:String? = ""
    var username:String? = ""
    var commentText:String? = ""
    var timeText:String? = ""
    var likeCount:Int? = 0
    var commentId:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.fetchCommentReply()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI(){
        let url = URL.init(string:self.profileImageString ?? "")
        profileImage.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        self.nameLabel.text = self.username ?? ""
        self.commentLabel.text = self.commentText ?? ""
        self.timeLbel.text = self.timeText ?? ""
        self.likeLabel.text = "like(\(self.likeCount ?? 0))"
        self.title = "Comments"
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 10
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1.0
        self.sendBtn.isCircular()
        self.adjustHeight()
        self.showImage.isHidden = true
        self.showLabel.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        self.tableView.register(UINib(nibName: "PPCommentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPCommentItemTableViewCellID")
    }
    @objc func refresh(sender:AnyObject) {
        self.replyCommentArray.removeAll()
        self.tableView.reloadData()
        self.fetchCommentReply()
        refreshControl.endRefreshing()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.addCommentReply()
        self.textView.text = ""

        
    }
    func reload(){
        self.tableView.reloadData()
        self.tableView.es.stopLoadingMore()
        if (self.contentIndexPath != nil) {
            self.tableView.scrollToRow(at: self.contentIndexPath!, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    func adjustHeight(){
        let size = self.textView.sizeThatFits(CGSize(width: self.textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightConstraint.constant = size.height
        self.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    private func addCommentReply(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let commentId = self.commentId ?? 0
            let text = self.textView.text ?? ""
            Async.background({
                ReplyCommentManager.instance.addCommentReply(accessToken: accessToken, commentId: commentId, Text: text, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.status ?? "")")
                                self.fetchCommentReply()
                                
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
    private func fetchCommentReply(){
        if Connectivity.isConnectedToNetwork(){
            self.replyCommentArray.removeAll()
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let commentId = self.commentId ?? 0
            Async.background({
                ReplyCommentManager.instance.getCommentReply(accessToken: accessToken, commentId: commentId, limit: 0, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                self.replyCommentArray = success?.data ?? []
                                if self.replyCommentArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showLabel.isHidden = false
                                    self.tableView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showLabel.isHidden = true
                                    self.tableView.reloadData()
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
extension CommentReplyVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
    }
}

extension CommentReplyVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.replyCommentArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPCommentItemTableViewCellID") as! PPCommentItemTableViewCell
        let object = self.replyCommentArray[indexPath.row]
        cell.replyCommentbind(item:object , viewModel: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
