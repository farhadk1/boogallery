//
//  AddPostPostVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 04/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import MediaPlayer
import ActionSheetPicker_3_0
import Async
import PixelPhotoSDK
import PixelPhotoFramework

class AddPostPostVC: BaseVC {
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionTextVIew: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var viewModel : AddPostViewModeling?
    var disposeBag = DisposeBag()
    var sdk = PixelPhotoSDK.shared
    var type:String? = ""
    var VideoData:Data? = nil
    var thumbData:Data? = nil
    var gifURLString:String? = ""
    var embbedVideoURLLink:String? = ""
    var imageArray = [UIImage]()
    var videoArray = [String]()
    var GifsArray = [ String]()
    var thumbnailiamgeArray = [UIImage]()
    var isEmptyMedia:Bool? = false
    private let placeholder = NSLocalizedString("Add post caption. #hashtag..@mention?", comment: "")
    
    
    
    var isLoaded = false
    
    var onRefresh: (() -> Void)?
    
    
    @IBOutlet weak var addToPostBtn: UIButton!
   
    private lazy var titleText : UIBarButtonItem = {
        return  UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }()
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setupView()
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func moreuserBtnpressed(_ sender: Any) {
        let vc = R.storyboard.post.addToPostVC()
        vc!.delegate = self
        self.present(vc!, animated: true, completion: nil) 
    }
    @IBAction func iamgeBtnPressed(_ sender: Any) {
        self.showImageAlert()
    }
    
    @IBAction func smileBtnpressed(_ sender: Any) {
        let vc = R.storyboard.post.addToPostVC()
        vc!.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func addPostPressed(_ sender: Any) {
        let vc = R.storyboard.post.addToPostVC()
        vc!.delegate = self
        self.present(vc!, animated: true, completion: nil) 
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
    
    private func setupUI(){
        self.textViewPlaceHolder()
        
        let url = URL.init(string:AppInstance.instance.userProfile?.data?.avatar ?? "")
        self.profileImage.sd_setImage(with: url , placeholderImage:R.image.img_item_placeholder())
        self.usernameLabel.text = "\(AppInstance.instance.userProfile?.data?.fname ?? "") \(AppInstance.instance.userProfile?.data?.lname ?? "")"
        self.typeLabel.text = self.type ?? ""
        
        if type == "GIF" {
            self.showGif()
        }else if type == "IMAGE" {
            self.showImageAlert()
        }else if type == "YOUTUBE" {
            let vc = R.storyboard.post.embbedVideoVC()
            vc!.delegate = self
            self.present(vc!, animated: true, completion: nil)
            
        }else if type == "VIDEO" {
            self.openVideoController()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(addTapped))
    }
    @objc func addTapped(sender: UIBarButtonItem) {
        if isEmptyMedia!{
            self.view.makeToast("Please select atleast one media.")
        }else{
            if type == "GIF" {
                self.uploadGif(GIFURL: self.gifURLString ?? "")
            }else if type == "IMAGE" {
                var imagesDataArray  = [Data]()
                self.imageArray.forEach { (it) in
                    let data = it.jpegData(compressionQuality: 0.1)
                    imagesDataArray.append(data!)
                    self.uploadImages(imageArray: imagesDataArray)
                }
            }else if type == "YOUTUBE" {
                self.uploadEmbbedURL(videoURL: self.embbedVideoURLLink ?? "")
            }else if type == "VIDEO" {
                self.uploadVideo(videoData: self.VideoData!, thumbData: self.thumbData)
            }
        }
       
    }
    
    func setupView(){
        self.navigationController?.isNavigationBarHidden = false

        self.addToPostBtn.setTitle(NSLocalizedString("Add to Post", comment: ""), for: UIControl.State.normal)
        
        self.collectionView.register(R.nib.ppPostItemCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.ppPostItemCollectionViewCellID.identifier)
    }
    private func showGif(){
        let vc = R.storyboard.post.gifvC()
        vc!.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func textViewPlaceHolder(){
        textView.delegate = self
        textView.text = placeholder
        textView.textColor = UIColor.lightGray
        
    }
    private func openVideoController(){
        self.type = "VIDEO"
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func showImageAlert(){
        self.type = "IMAGE"
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("Source", comment: ""),
                                     rows: [NSLocalizedString("Gallery", comment: ""),
                                            NSLocalizedString("Camera", comment: "")
            ],
                                     initialSelection: 0,
                                     doneBlock: { (picker, value, index) in
                                        
                                        if value == 0 {
                                            let imagePickerController = UIImagePickerController()
                                            
                                            imagePickerController.delegate = self
                                            
                                            imagePickerController.allowsEditing = true
                                            imagePickerController.sourceType = .photoLibrary
                                            self.present(imagePickerController, animated: true, completion: nil)
                                            
                                            
                                        }else if value == 1 {
                                            let imagePickerController = UIImagePickerController()
                                            
                                            imagePickerController.delegate = self
                                            
                                            imagePickerController.allowsEditing = true
                                            imagePickerController.sourceType = .camera
                                            self.present(imagePickerController, animated: true, completion: nil)
                                        }
                                        return
                                        
        }, cancel:  { ActionStringCancelBlock in return }, origin:self.view)
        
    }
    private func uploadImages(imageArray:[Data]){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let caption = self.textView.text ?? ""
        Async.background({
            
            AddPostManager.instance.addImages(accessToken: accessToken, caption: caption, imageDataArray: imageArray, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            AppInstance.instance.fetchUserProfile()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            
                        }                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    })
                }
            })
        })
    }
    private func uploadVideo(videoData:Data,thumbData:Data?){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let caption = self.textView.text ?? ""
        Async.background({
            AddPostManager.instance.addVideo(accessToken: accessToken, caption: caption, videoData: videoData, thumbImageData: thumbData, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            AppInstance.instance.fetchUserProfile()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            
                        }                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    })
                }
            })
        })
    }
    private func uploadGif(GIFURL:String){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let caption = self.textView.text ?? ""
        Async.background({
            AddPostManager.instance.postGiF(accessToken: accessToken, GIFUrl: GIFURL, caption: caption, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            AppInstance.instance.fetchUserProfile()
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            
                        }                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    })
                }
            })
        })
    }
    private func uploadEmbbedURL(videoURL:String){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let caption = self.textView.text ?? ""
        Async.background({
            AddPostManager.instance.postEmbbedLinks(accessToken: accessToken, VidoeLink: videoURL, caption: caption, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            AppInstance.instance.fetchUserProfile()
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            
                        }                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    })
                }
            })
        })
    }
    private func adjustHeight(){
        let size = self.textView.sizeThatFits(CGSize(width: self.textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightConstraint.constant = size.height
        self.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
}
extension AddPostPostVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            self.textView.text = ""
            textView.textColor = UIColor.black 
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
            
            
        }
    }
}

extension AddPostPostVC : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if type == "IMAGE"{
            return self.imageArray.count
        } else if type == "VIDEO"{
            return self.videoArray.count
        }else if type == "GIF"{
            return self.GifsArray.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        self.currentIndexPath = indexPath
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPPostItemCollectionViewCellID", for: indexPath) as! PPPostItemCollectionViewCell
        cell.vc = self
        if type == "GIF" {
            cell.gifBinding(gifURL: self.GifsArray[indexPath.row], row: indexPath.row, Type:  self.type ?? "")
            
        }else if type == "IMAGE" {
            
            cell.imageBinding(image: self.imageArray[indexPath.row], row: indexPath.row, Type:  self.type ?? "")
            
        }else if type == "YOUTUBE" {
            
        }else if type == "VIDEO" {
            
            cell.videoBinding(videoThumb: self.thumbnailiamgeArray[indexPath.row], row: indexPath.row, Type:  self.type ?? "")
            
        }
        
        return cell
        
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.size.width / 3 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
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

extension AddPostPostVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if self.type == "IMAGE" {
            self.isEmptyMedia = false
            self.videoArray.removeAll()
            self.GifsArray.removeAll()
            let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.imageArray.append(img!)
            self.collectionView.reloadData()
        } else if self.type == "VIDEO" {
            self.isEmptyMedia = false

            self.videoArray.removeAll()
            let vidURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            self.videoArray.append(vidURL.absoluteString)
            let ThumbnailIamge =  self.generateThumbnail(path: vidURL)
            self.thumbnailiamgeArray.append(ThumbnailIamge!)
            self.collectionView.reloadData()
            let videoData = try! Data(contentsOf: vidURL)
            
            self.VideoData = videoData
            self.thumbData = ThumbnailIamge?.jpegData(compressionQuality: 0.1)
            print(videoData)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
extension AddPostPostVC:didSelectType{
    func didselecttype(type: String) {
        if type == "IMAGE"{
            self.showImageAlert()
            self.type = "IMAGE"
        }
        if type == "VIDEO"{
            self.openVideoController()
            self.type = "VIDEO"
        }
        if type == "YOUTUBE"{
            let vc = R.storyboard.post.embbedVideoVC()
            vc!.delegate = self
            self.present(vc!, animated: true, completion: nil)
            self.type = "YOUTUBE"
        }
        if type == "GIF"{
            self.showGif()
            self.type = "GIF"
        }
        
    }
}

extension AddPostPostVC:didSelectEmbbedVideoDelegate{
    func didSelectEmbbedVideo(videoURL: String) {
        self.mentionTextVIew.text = videoURL
        self.embbedVideoURLLink = videoURL
    }
}
extension AddPostPostVC:didSelectGIFDelegate{
    func didSelectGIF(GIFUrl: String) {
        self.isEmptyMedia = false
        self.GifsArray.removeAll()
        self.collectionView.reloadData()
        self.GifsArray.append(GIFUrl)
        self.gifURLString = GIFUrl
        self.type = "GIF"
        self.collectionView.reloadData()
        
    }
}

