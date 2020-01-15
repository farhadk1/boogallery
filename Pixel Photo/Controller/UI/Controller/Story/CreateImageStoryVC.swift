//
//  CreateImageStoryVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 03/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import MMPlayerView
import AVFoundation
import SDWebImage
import Async
import PixelPhotoSDK

class CreateImageStoryVC: BaseVC {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var captionTxtView: UITextView!
    @IBOutlet weak var contentImgView: UIImageView!
    
    var videoLinkString:String? = ""
    var imageLInkString:String? = ""
    var iamge:UIImage? = nil
    var isVideo:Bool? = false
    
    private var aspectConstraint: NSLayoutConstraint?
    
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 200)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false

    }
    @IBAction func sendPressed(_ sender: Any) {
        self.createStory()
    }
    
    func setupUI(){
      self.title = "Add Story"
        self.sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: UIControl.State.normal)
        
        if self.aspectConstraint != nil {
            self.contentImgView.removeConstraint(self.aspectConstraint!)
        }
        
        if let image = iamge{
            let aspectRatio = (image as UIImage).size.height/(image as UIImage).size.width
            self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: self.contentImgView,
                                                       attribute: .width,
                                                       multiplier: aspectRatio,
                                                       constant: 0)
            
            self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
            self.contentImgView.addConstraint(self.aspectConstraint!)
            
            // self.mmPlayerLayer.thumbImageView.image = image.resizeImage(aspectRation: aspectRatio)
        }else{
            
            self.mmPlayerLayer.thumbImageView.sd_setImage(with: URL(string: (imageLInkString)!),
                                                          placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                            
                                                            
                                                            if error != nil {
                                                                DispatchQueue.main.async {
                                                                    self.mmPlayerLayer.thumbImageView.image = UIImage(named: "img_item_placeholder")
                                                                }
                                                            }else{
                                                                SDImageCache.shared.store(image, forKey: (self.imageLInkString)!, completion: {
                                                                    
                                                                    let aspectRatio = (image! as UIImage).size.height/(image! as UIImage).size.width
                                                                    
                                                                    self.aspectConstraint = NSLayoutConstraint(item: self.contentImgView,
                                                                                                               attribute: .height,
                                                                                                               relatedBy: .equal,
                                                                                                               toItem: self.contentImgView,
                                                                                                               attribute: .width,
                                                                                                               multiplier: aspectRatio,
                                                                                                               constant: 0)
                                                                    
                                                                    self.aspectConstraint?.priority = UILayoutPriority(rawValue: 999)
                                                                    self.contentImgView.addConstraint(self.aspectConstraint!)
                                                                    
                                                                    //self.mmPlayerLayer.thumbImageView.image = image!.resizeImage(aspectRation: aspectRatio)
                                                                })
                                                            }
                                                            
                                                            
            }
        }
        
        
        if (isVideo)! {
            self.mmPlayerLayer.playView = self.contentImgView
            mmPlayerLayer.replace(cover:  CoverView.instantiateFromNib())
            mmPlayerLayer.showCover(isShow: true)
            
            self.mmPlayerLayer.set(url: URL(string:(self.videoLinkString)!))
            self.mmPlayerLayer.resume()
            
            mmPlayerLayer.getStatusBlock { [weak self] (status) in
                switch status {
                case .failed( _):
                    print("Failed")
                case .ready:
                    print("Ready to Play")
                case .playing:
                    print("Playing")
                case .pause:
                    print("Pause")
                case .end:
                    print("End")
                default: break
                }
            }
        }else{
            self.contentImgView.image = UIImage(contentsOfFile: (imageLInkString)!)
        }
    }
   
    private func createStory(){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let text = self.captionTxtView.text ?? ""
        Async.background({
            if self.isVideo!{
                let videoData = try? Data(contentsOf: URL(string:(self.videoLinkString!))!)
                StoryManager.instance.createStory(accessToken: accessToken, story_data: videoData, mimeType: videoData!.mimeType, type: "video", text: text, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.data?.message ?? "")")
                                self.view.makeToast(success?.data?.message ?? "")
                            }
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                                self.navigationController?.popViewController(animated: true)

                            }
                            
                        })
                        
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                        
                    }
                })
            }else{
                let image = self.iamge?.jpegData(compressionQuality: 0.2)
                StoryManager.instance.createStory(accessToken: accessToken, story_data: image, mimeType: image!.mimeType, type: "image", text: text, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.data?.message ?? "")")
                                self.view.makeToast(success?.data?.message ?? "")
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            }
                            
                        })
                        
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                        
                    }
                })
            }
            
        })
    }
}
