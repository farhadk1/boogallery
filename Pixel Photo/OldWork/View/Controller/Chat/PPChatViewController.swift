//
//  PPChatViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 08/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework
import ActionSheetPicker_3_0
import SDWebImage

class PPChatViewController: UIViewController {
    
    var viewModel : ChatViewModeling?
    var disposeBag:DisposeBag! = DisposeBag()
    
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTxtViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentTblView: UITableView!
    
    private lazy var optionBtn: UIButton = {
        let chatBtn = UIButton(type: .custom)
        chatBtn.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 10)
        chatBtn.setImage(UIImage(named:"ic_action_more"), for: .normal)
        chatBtn.imageView?.contentMode = .scaleAspectFit
        return chatBtn
    }()
    
    private lazy var receiverNameLbl: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.disposeBag = nil
    }
    
    
    func setupView(){
        
        self.navigationController?.isNavigationBarHidden = false
        
        let optionBtnItem = UIBarButtonItem(customView: optionBtn)
        navigationItem.rightBarButtonItems = [optionBtnItem]
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.sendBtn.isCircular()
        self.messageTxtView.delegate = self
        self.messageTxtView.layer.cornerRadius = 10
        self.messageTxtView.layer.borderColor = UIColor.lightGray.cgColor
        self.messageTxtView.layer.borderWidth = 1.0
        
        self.contentTblView.register(UINib(nibName: "PPReceiverChatItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPReceiverChatItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPSenderChatItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPSenderChatItemTableViewCellID")
        
        if "\((self.viewModel?.user!.fname!)!) \((self.viewModel?.user!.lname!)!)" == "" {
            self.receiverNameLbl.text = "\((self.viewModel?.user!.fname!)!) \((self.viewModel?.user!.lname!)!)"
            self.navigationItem.titleView = self.receiverNameLbl
        }else{
            self.receiverNameLbl.text = "\((self.viewModel?.user!.uname!)!)"
            self.navigationItem.titleView = self.receiverNameLbl
        }
        
        self.adjustHeight()
    }
    
    func setupRx(){
        
        self.messageTxtView.rx.text.orEmpty.bind(to: (self.viewModel?.messageTxt)!).disposed(by: self.disposeBag)
        
        Observable<Int>.timer(0, period: Double(ControlSettings.RefreshChatActivitiesSeconds * 6), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: -1)
            .filter({$0 != 0})
            .drive(onNext : { value in
                self.viewModel?.isInitialize.accept(true)
            }).disposed(by: self.disposeBag)
        
        
        self.viewModel?.cleanText
            .asDriver()
            .drive(onNext : { _ in
                self.view.endEditing(true)
                self.messageTxtView.text = ""
                self.viewModel?.messageTxt.accept("")
            }).disposed(by:self.disposeBag)
        
        self.optionBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.showMoreOption()
            }).disposed(by:self.disposeBag)
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                self.viewModel?.isInitialize.accept(true)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.messages
            .asDriver()
            .drive(onNext : { _ in
                self.reload()
            }).disposed(by: self.disposeBag)
        
        self.sendBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.viewModel?.sendMessage.accept(true)
            }).disposed(by:self.disposeBag)
    }
    
    func showMoreOption(){
        var selection:[String] = []
        
        if (self.viewModel?.isBlocked)! {
            selection = ["Unblock","Clear Chat"]
        }else{
            selection = ["Block","Clear Chat"]
        }
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Option", comment: ""),
                                     rows: selection,
                                     initialSelection: 0,
                                     doneBlock: { (picker, value, index) in
                                        
                                        if value == 0 {
                                            self.viewModel?.blockUnblockUser.accept(true)
                                        }else {
                                            self.viewModel?.clearMessagesTrig.accept(true)
                                        }
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin: self.optionBtn)
    }
    
    func reload(){
        self.contentTblView.reloadData()
        self.contentTblView.es.stopLoadingMore()
        
        print((self.viewModel?.messages.value.count)!)
        
        if (self.viewModel?.messages.value.count)! > 0 {
            let indexPath = NSIndexPath(item: ((self.viewModel?.messages.value.count)! - 1), section: 0)
            self.contentTblView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
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

extension PPChatViewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
    }
}

extension PPChatViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.viewModel?.messages.value[indexPath.row]
            self.viewModel?.deleteMessageItem.accept(item)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.messages.value.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.viewModel?.messages.value[indexPath.row]
        
        if item!.position == "right" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPSenderChatItemTableViewCellID") as! PPSenderChatItemTableViewCell
//            cell.bind(item: item!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPReceiverChatItemTableViewCellID") as! PPReceiverChatItemTableViewCell
//        cell.bind(item: item!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
