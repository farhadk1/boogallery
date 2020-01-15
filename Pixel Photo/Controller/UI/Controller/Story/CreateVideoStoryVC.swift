//
//  CreateVideoStoryVC.swift
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

class CreateVideoStoryVC: BaseVC {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var captionTxtView: UITextView!
    @IBOutlet weak var contentImgView: UIImageView!
    
    
    var viewModel : PPStorySubmitViewModeling?
    var videoLinkString:String? = ""
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

        self.mmPlayerLayer.playView = self.contentImgView
        mmPlayerLayer.replace(cover:  CoverView.instantiateFromNib())
        mmPlayerLayer.showCover(isShow: true)
        
        self.mmPlayerLayer.set(url: URL(string:(videoLinkString!)))
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
    }
    
        private func createStory(){
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let text = self.captionTxtView.text ?? ""
            Async.background({
                let videoData = try? Data(contentsOf: URL(string:(self.videoLinkString!))!)
                
                StoryManager.instance.createStory(accessToken: accessToken, story_data: videoData, mimeType: videoData!.mimeType, type: "video", text: text, completionBlock: { (success, sessionError, error) in
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
            })
        }
    
    
}
