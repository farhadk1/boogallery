//
//  UserSuggestionVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 21/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import RxViewController
import UIScrollView_InfiniteScroll
import Async
import PixelPhotoSDK


class UserSuggestionVC: BaseVC {
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    private var suggestedUsersArray = [SuggestedUserModel.Datum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.fetchUserSuggestions()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    func setupUI(){
        self.title = NSLocalizedString("User Suggestion", comment: "")
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: Selector("done"))
        self.navigationItem.rightBarButtonItem = done
        self.contentCollectionView.register(R.nib.userSuggestionCollectionCell(), forCellWithReuseIdentifier: R.reuseIdentifier.userSuggestionCollectionCell.identifier)
    }
    
    @objc func done(){
       let vc = R.storyboard.dashboard.tabbarVC()
        self.present(vc!, animated: true, completion: nil)
    }
    private func fetchUserSuggestions(){
        if appDelegate.isInternetConnected{
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                SuggestedUserManager.instance.getsuggestedUser(accessToken: accessToken, limit: 20, offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.suggestedUsersArray = success?.data ?? []
                                self.contentCollectionView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        })
                    }
                })
            })
        }else{
             log.error(InterNetError)
            self.view.makeToast(InterNetError)
        }
       
    }
    
}

extension UserSuggestionVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return (self.suggestedUsersArray.count)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.userSuggestionCollectionCell.identifier, for: indexPath) as! UserSuggestionCollectionCell
       let object = self.suggestedUsersArray[indexPath.row]
        cell.vc = self
        cell.userId = object.userID ?? 0
        cell.userNameLbl.text = object.username ?? ""
        cell.profileNameLbl.text = object.name ?? ""
        let url = URL.init(string:object.avatar ?? "")
        log.verbose("userId = \(object.userID ?? 0 )")
        cell.profileImgView.sd_setImage(with: url , placeholderImage:R.image.img_profile_placeholder())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
