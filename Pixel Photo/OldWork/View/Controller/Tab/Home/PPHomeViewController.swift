//
//  PPHomeViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import ActionSheetPicker_3_0

class PPHomeViewController: PPBaseViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    var offsetObservation: NSKeyValueObservation?
    
    var disposeBag = DisposeBag()
    var viewModel : HomeViewModeling?
    var alreadyInitialize = false
    var shouldRefreshStories = false
    
    var contentIndexPath : IndexPath?
    //    let titleText = UIBarButtonItem(title: "Pixel Photo", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    
    var isVideo = false
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRx()
        //        _ = NotificationCenter.default.rx
        //            .notification(Notification.Name(rawValue: "update_data"))
        //            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
        //            .subscribe(onNext: { notification in
        //                self.alreadyInitialize = false
        //            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        
    }
    
    func setupView(){
        
        self.navigationItem.title = NSLocalizedString("App Name", comment: "")
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.estimatedRowHeight = 400
        
        self.contentTblView.register(UINib(nibName: "PPYoutubeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPYoutubeItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPMultiImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPMultiImageItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPLinkItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPLinkItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPVideoItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPVideoItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPGIFItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPGIFItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPImageItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPCollectionViewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPCollectionViewItemTableViewCellID")
        
        self.navigationController?.mmPlayerTransition.push.pass(setting: { (_) in
            
        })
        
        self.contentTblView.es.addPullToRefresh {
            [unowned self] in
            self.viewModel!.state.accept(DATASTATUS.PULLTOREFRESH)
        }
        
        self.contentTblView.es.addInfiniteScrolling {
            [unowned self] in
            self.viewModel?.state.accept(DATASTATUS.LOADMORE)
        }
    }
    
    func setupRx(){
        
        self.viewModel?.shouldRefresh.asDriver()
            .filter({$0 != false})
            .drive(onNext : { value in
                self.viewModel?.isInitialize.accept(true)
            }).disposed(by: self.disposeBag)
        
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
        
//        self.viewModel?.finishedInfiniteScroll
//            .asDriver()
//            .filter({$0})
//            .drive(onNext : { _ in
//                self.contentTblView.reloadData()
//                self.contentTblView.es.stopLoadingMore()
//                
//                if (self.contentIndexPath != nil) {
//                    self.contentTblView.scrollToRow(at: self.contentIndexPath!, at: UITableView.ScrollPosition.bottom, animated: true)
//                }
//            }).disposed(by: self.disposeBag)
        
        self.viewModel?.finishedPullToRefresh
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.contentTblView.reloadData()
                    self.contentTblView.es.stopPullToRefresh()
                    self.contentTblView.es.resetNoMoreData()
                }
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
        
        self.rx.viewDidAppear
            .asDriver()
            .drive(onNext : { value in
                if !self.alreadyInitialize {
                    self.alreadyInitialize = true
                    self.viewModel?.isInitialize.accept(true)
                }else if self.shouldRefreshStories {
                    self.shouldRefreshStories = false
                    self.viewModel?.refreshStories.accept(true)
                }
                
                 self.navigationController?.isNavigationBarHidden = false
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.notificationNum
            .asDriver(onErrorJustReturn: 0)
            .filter({_ in self.alreadyInitialize})
            .drive(onNext : { value in
                if let tabItems = self.tabBarController?.tabBar.items {
                    if value == 0 {
                        let tabItem = tabItems[3]
                        tabItem.badgeValue = nil
                    }else{
                        let tabItem = tabItems[3]
                        tabItem.badgeValue = "\(value!)"
                    }
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.goBack
            .asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.storiesItems
            .asDriver()
            .filter({$0.count > 0})
            .drive(onNext : { value in
                self.alreadyInitialize = true
                self.contentTblView.reloadData()
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.userItem
            .asDriver()
            .filter({$0 != nil})
            .drive(onNext : {  value in
                self.contentTblView.reloadData()
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
    
    func showAddStory(cell:UICollectionViewCell){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Add Story", comment: ""),
                                     rows: [NSLocalizedString("Text", comment: ""),NSLocalizedString("Image", comment: ""),NSLocalizedString("Video", comment: ""),NSLocalizedString("Camera", comment: "")],
                                     initialSelection: 0,
                                     doneBlock: { (picker, value, index) in
                                        
                                        if value == 0 {
                                            self.shouldRefreshStories = true
                                            self.isVideo = false
//                                            SwinjectStoryboard.defaultContainer.assembleTextStory()
//                                            let sb = SwinjectStoryboard.create(name: "Story",
//                                                                               bundle: nil,
//                                                                               container: SwinjectStoryboard.defaultContainer)
//                                            let nextVC = sb.instantiateViewController(withIdentifier: "PPStoryTextViewControllerID") as! PPStoryTextViewController
//                                            nextVC.hidesBottomBarWhenPushed = true
//                                            self.navigationController?.pushViewController(nextVC, animated: true)
                                        }else if value == 1 {
                                            self.isVideo = false
                                            let imagePickerController = UIImagePickerController()
                                            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                                            imagePickerController.mediaTypes = ["public.image"]
                                            imagePickerController.delegate = self
                                            self.present(imagePickerController, animated: true, completion: nil)
                                        }else if value == 2 {
                                            self.isVideo = true
                                            let imagePickerController = UIImagePickerController()
                                            imagePickerController.sourceType = .photoLibrary
                                            imagePickerController.mediaTypes = ["public.movie"]
                                            imagePickerController.delegate = self
                                            self.present(imagePickerController, animated: true, completion: nil)
                                        }else{
                                            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                                                self.isVideo = false
                                                let imagePickerController = UIImagePickerController()
                                                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                                                imagePickerController.allowsEditing = false
                                                imagePickerController.delegate = self
                                                self.present(imagePickerController, animated: true, completion: nil)
                                            }else{
                                                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                        
                                        return
        }, cancel:  { ActionStringCancelBlock in return }, origin: cell)
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

extension PPHomeViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            if self.isVideo {
                let vidURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
//                SwinjectStoryboard.defaultContainer.assembleTextVideoStorySubmit(fileUrl:vidURL.absoluteString , isVideo: self.isVideo)
//                let sb = SwinjectStoryboard.create(name: "Story",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPStoryVideoSubmitViewControllerID") as! PPStoryVideoSubmitViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
            }else{
                let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//                SwinjectStoryboard.defaultContainer.assembleTextStorySubmit(fileUrl: FileManager().savePostImage(image: img!), isVideo: self.isVideo)
//                let sb = SwinjectStoryboard.create(name: "Story",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPStorySubmitViewControllerID") as! PPStorySubmitViewController
//                nextVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


extension PPHomeViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.viewModel?.storiesItems.value.count)! + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPYourStoryItemCollectionViewCellID", for: indexPath) as! PPYourStoryItemCollectionViewCell
            if self.viewModel?.userItem.value != nil {
                cell.bind(item: (self.viewModel?.userItem.value)!)
            }
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPStoryItemCollectionViewCellID", for: indexPath) as! PPStoryItemCollectionViewCell
        cell.bind(item:  (self.viewModel?.storiesItems.value)![indexPath.row - 1], row: indexPath.row)
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        if indexPath.row != 0 {
//            self.shouldRefreshStories = true
//            PPStoriesItemsViewControllerVC = UIStoryboard(name: "Story", bundle: nil).instantiateViewController(withIdentifier: "PPStoriesItemsViewControllerID") as! PPStoriesItemsViewController
//            let vc = PPStoriesItemsViewController
//            vc.refreshStories = {
//                self.viewModel?.refreshStories.accept(true)
//            }
//            vc.modalPresentationStyle = .overFullScreen
//            vc.pages = (self.viewModel?.storiesItems.value)!
//            vc.currentIndex = indexPath.row - 1
//            self.present(vc, animated: true, completion: nil)
//        }else{
//            guard let cell = collectionView.cellForItem(at: indexPath) else {
//                return
//            }
//            
//            self.showAddStory(cell: cell)
//        }
//    }
//    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80 , height: 120)
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

extension PPHomeViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel!.postItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.contentIndexPath = indexPath
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPCollectionViewItemTableViewCellID") as! PPCollectionViewItemTableViewCell
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            return cell
        }
        
        let item = self.viewModel?.postItems[indexPath.row - 1]
        
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
        
        if indexPath.row == 0 {
            return 120
        }
        
        return UITableView.automaticDimension
    }
    
}
