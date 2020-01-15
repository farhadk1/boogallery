//
//  PPChatListViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 18/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import PixelPhotoFramework

class PPChatListViewController: UIViewController {
    
    @IBOutlet weak var addUserView: UIView!
    @IBOutlet weak var contentTblView: UITableView!
    
    var disposeBag = DisposeBag()
    var viewModel : ChatListViewModeling?
    var sdk = PixelPhotoSDK.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPChatUserItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPChatUserItemTableViewCellID")
        
        self.addUserView.isCircular()
    }
    
    func setupRx(){
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                self.viewModel?.isInitialize.accept(true)
            }).disposed(by: self.disposeBag)
        
//        self.addUserView.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe({ _ in
//                SwinjectStoryboard.defaultContainer.assembleFollowerFollowing(type: PROFILEMODE.CHAT, userID: self.sdk.getMyUserID())
//                let sb = SwinjectStoryboard.create(name: "Profile",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPFollowerFollowingViewControllerID") as! PPFollowerFollowingViewController
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }).disposed(by: self.disposeBag)
        
        self.viewModel?.items
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
extension PPChatListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.viewModel?.deleteUserChat.accept(self.viewModel?.items.value[indexPath.row])
            var temp = self.viewModel?.items.value
            temp?.remove(at: indexPath.row)
            self.viewModel?.items.accept(temp!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.items.value.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPChatUserItemTableViewCellID") as! PPChatUserItemTableViewCell
//        cell.bind(item: self.viewModel!.items.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        SwinjectStoryboard.defaultContainer.assembleChatItem(user: self.viewModel!.items.value[indexPath.row].user_data!)
//        let sb = SwinjectStoryboard.create(name: "Chat",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let nextVC = sb.instantiateViewController(withIdentifier: "PPChatViewControllerID") as! PPChatViewController
//        self.navigationController?.pushViewController(nextVC, animated: true)
//        
//    }
    
}
