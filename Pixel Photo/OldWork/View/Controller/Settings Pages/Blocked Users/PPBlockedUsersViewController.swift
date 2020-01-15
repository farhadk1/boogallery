//
//  PPBlockedUsersViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 20/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPBlockedUsersViewController: UIViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var disposeBag = DisposeBag()
    var viewModel : SettingsViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPBlockedUserItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPBlockedUserItemTableViewCellID")
    }
    
    func setupRx(){
        
        self.rx
            .viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                self.viewModel?.isInitialize.accept(true)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.blockedUsers
            .asDriver()
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
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

extension PPBlockedUsersViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .default, title: "Unblock", handler: {
            (action, indexPath) in
            self.viewModel?.blockUnblockUser.accept(self.viewModel?.blockedUsers.value[indexPath.row])
        })
        action1.backgroundColor = UIColor.lightGray
        return [action1]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.blockedUsers.value.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPBlockedUserItemTableViewCellID") as! PPBlockedUserItemTableViewCell
//        cell.bind(item: (self.viewModel?.blockedUsers.value[indexPath.row])!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
