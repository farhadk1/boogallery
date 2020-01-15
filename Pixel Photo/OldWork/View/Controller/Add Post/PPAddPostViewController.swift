//
//  PPAddPostViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 09/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MediaPlayer
import PixelPhotoFramework

class PPAddPostViewController: UIViewController {
    
    var viewModel : AddPostViewModeling?
    var disposeBag = DisposeBag()
    var sdk = PixelPhotoSDK.shared
    
    var isLoaded = false
    
    var onRefresh: (() -> Void)?
    
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var addToPostBtn: UIButton!
    
    private lazy var saveBtn : UIBarButtonItem = {
        return  UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }()
    
    private lazy var titleText : UIBarButtonItem = {
        return  UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }()
    
    private lazy var backBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        btn.setImage(UIImage(named: "ic_back_black"), for: UIControl.State.normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
//        setupRx()
    }
    
    func keyboardHeight() -> Observable<CGFloat> {
        return Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                }
                ])
            .merge()
    }
    
    
    func setupView(){
        self.navigationController?.isNavigationBarHidden = false
        
        navigationItem.rightBarButtonItems = [saveBtn]
        
        let backBarItem = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItems = [backBarItem,titleText]
        
        self.addToPostBtn.setTitle(NSLocalizedString("Add to Post", comment: ""), for: UIControl.State.normal)
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.contentTblView.register(UINib(nibName: "PPAddPostCaptionTableViewCell", bundle: nil), forCellReuseIdentifier: "PPAddPostCaptionTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPHorizontalCollectionviewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPHorizontalCollectionviewItemTableViewCellID")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLoaded {
            isLoaded = true
            
            if self.viewModel?.type.value == POSTTYPE.GIF {
//                SwinjectStoryboard.defaultContainer.assembleSelectGif(gifList: (self.viewModel?.gifList)!)
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPSelectGIFViewControllerID") as! PPSelectGIFViewController
//                nextVC.onClickedItem = { item in
//                    self.viewModel?.gifUrl.accept((item.images?.fixed_height?.mp4!)!)
//                }
//                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.viewModel?.type.value == POSTTYPE.IMAGE {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePickerController.mediaTypes = ["public.image"]
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }else if self.viewModel?.type.value == POSTTYPE.IMAGES {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePickerController.mediaTypes = ["public.image"]
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }else if self.viewModel?.type.value == POSTTYPE.YOUTUBE {
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "PPEmbedVideoViewControllerID") as! PPEmbedVideoViewController
//                self.navigationController?.present(nextVC, animated: true, completion: {
//                    nextVC.urlTxtView.rx.text.orEmpty.bind(to: ((self.viewModel?.postLinkURL)!)).disposed(by: self.disposeBag)
                }
            }else if self.viewModel?.type.value == POSTTYPE.VIDEO {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.mediaTypes = ["public.movie"]
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
//    func setupRx(){
//
//        self.viewModel?.dismissPage
//            .asDriver()
//            .filter({$0})
//            .drive(onNext : { arg in
//                self.dismiss(animated: true, completion: {
//                    self.onRefresh!()
//                })
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.type
//            .asDriver(onErrorJustReturn: POSTTYPE.NONE)
//            .drive(onNext : { _ in
//                self.contentTblView.reloadData()
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel?.onErrorTrigger
//            .asDriver()
//            .filter({$0.0 != ""})
//            .drive(onNext : { arg in
//                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
//            }).disposed(by: self.disposeBag)
//
//        self.addToPostBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                let sb = SwinjectStoryboard.create(name: "Post",
//                                                   bundle: nil,
//                                                   container: SwinjectStoryboard.defaultContainer)
//                let nextVC = sb.instantiateViewController(withIdentifier: "AddToPostViewControllerID") as! AddToPostViewController
//                nextVC.onClicked = { option in
//                    switch option {
//                    case POSTSOURCE.IMAGES:
//                        self.viewModel?.type.accept(POSTTYPE.IMAGES)
//                        let imagePickerController = UIImagePickerController()
//                        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
//                        imagePickerController.mediaTypes = ["public.image"]
//                        imagePickerController.delegate = self
//                        self.present(imagePickerController, animated: true, completion: nil)
//                        break
//                    case POSTSOURCE.VIDEOGALLERY:
//                        self.viewModel?.type.accept(POSTTYPE.VIDEO)
//                        let imagePickerController = UIImagePickerController()
//                        imagePickerController.sourceType = .photoLibrary
//                        imagePickerController.mediaTypes = ["public.movie"]
//                        imagePickerController.delegate = self
//                        self.present(imagePickerController, animated: true, completion: nil)
//                        break
//                    case POSTSOURCE.MENTIONEDCONTACTS:
//                        SwinjectStoryboard.defaultContainer.assembleFollowerFollowing(type: PROFILEMODE.MENTIONEDFOLLOWER, userID: self.sdk.getMyUserID())
//                        let sb = SwinjectStoryboard.create(name: "Profile",
//                                                           bundle: nil,
//                                                           container: SwinjectStoryboard.defaultContainer)
//                        let nextVC = sb.instantiateViewController(withIdentifier: "PPFollowerFollowingViewControllerID") as! PPFollowerFollowingViewController
//                        nextVC.onUserSelects = { items in
//                            print(items.count)
//                            self.viewModel?.mentionedContact.accept(items)
//                        }
//                        self.navigationController?.pushViewController(nextVC, animated: true)
//                        break
//                    case POSTSOURCE.CAMERA:
//                        self.viewModel?.type.accept(POSTTYPE.IMAGE)
//                        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
//                            let imagePickerController = UIImagePickerController()
//                            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
//                            imagePickerController.allowsEditing = false
//                            imagePickerController.delegate = self
//                            self.present(imagePickerController, animated: true, completion: nil)
//                        }else{
//                            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
//                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                        break
//                    case POSTSOURCE.GIF:
//                        self.viewModel?.type.accept(POSTTYPE.GIF)
//                        SwinjectStoryboard.defaultContainer.assembleSelectGif(gifList: (self.viewModel?.gifList)!)
//                        let sb = SwinjectStoryboard.create(name: "Post",
//                                                           bundle: nil,
//                                                           container: SwinjectStoryboard.defaultContainer)
//                        let nextVC = sb.instantiateViewController(withIdentifier: "PPSelectGIFViewControllerID") as! PPSelectGIFViewController
//                        nextVC.onClickedItem = { item in
//                            self.viewModel?.gifUrl.accept((item.images!.fixed_height_still?.url!)!)
//                        }
//                        self.navigationController?.pushViewController(nextVC, animated: true)
//                        break
//                    default: //Video
//                        self.viewModel?.type.accept(POSTTYPE.YOUTUBE)
//                        let sb = SwinjectStoryboard.create(name: "Post",
//                                                           bundle: nil,
//                                                           container: SwinjectStoryboard.defaultContainer)
//                        let nextVC = sb.instantiateViewController(withIdentifier: "PPEmbedVideoViewControllerID") as! PPEmbedVideoViewController
//                        self.navigationController?.present(nextVC, animated: true, completion: {
//                            nextVC.urlTxtView.rx.text.orEmpty.bind(to: ((self.viewModel?.postLinkURL)!)).disposed(by: self.disposeBag)
//                        })
//                        break
//                    }
//                }
//                self.navigationController?.present(nextVC, animated: true, completion: {
//
//                })
//            }).disposed(by:self.disposeBag)
//
//        self.viewModel!.gifUrl
//            .asDriver(onErrorJustReturn: "")
//            .drive(onNext : { _ in
//                self.contentTblView.reloadData()
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel!.videoUrl
//            .asDriver(onErrorJustReturn: "")
//            .drive(onNext : { _ in
//                self.contentTblView.reloadData()
//            }).disposed(by: self.disposeBag)
//
//        self.viewModel!.postLinkURL
//            .asDriver(onErrorJustReturn: "")
//            .drive(onNext : { _ in
//                self.contentTblView.reloadData()
//            }).disposed(by: self.disposeBag)
//
//        self.saveBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                self.viewModel?.submitData.accept(true)
//            }).disposed(by:self.disposeBag)
//
//
//        self.backBtn.rx.tap
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .subscribe({ _ in
//                self.dismiss(animated: true, completion: nil)
//            }).disposed(by:self.disposeBag)
//    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

extension PPAddPostViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PPAddPostCaptionTableViewCellID") as! PPAddPostCaptionTableViewCell
//            cell.bind(viewModel: self.viewModel!, tblview: self.contentTblView)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPHorizontalCollectionviewItemTableViewCellID") as! PPHorizontalCollectionviewItemTableViewCell
//        cell.bind(viewModel: sel  f.viewModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            return 250
        }
        return UITableView.automaticDimension
    }
    
    
}

extension PPAddPostViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if self.viewModel?.type.value == POSTTYPE.IMAGE ||  self.viewModel?.type.value == POSTTYPE.IMAGES {
            
            let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            
            var temp = self.viewModel?.imageURLs.value
            temp?.append(FileManager().savePostImage(image: img!))
            self.viewModel?.imageURLs.accept(temp!)
            
            var tempImgs = self.viewModel?.images.value
            tempImgs?.append(img!)
            self.viewModel?.images.accept(tempImgs!)
            
        } else if  self.viewModel?.type.value == POSTTYPE.VIDEO {
            let vidURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            self.viewModel?.videoUrl.accept(vidURL.absoluteString)
            
        }
        
        picker.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
}
