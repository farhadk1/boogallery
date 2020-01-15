//
//  PPStorySubmitViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MMPlayerView
import AVFoundation
import SDWebImage

class PPStorySubmitViewController: UIViewController {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var captionTxtView: UITextView!
    @IBOutlet weak var contentImgView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    var viewModel : PPStorySubmitViewModeling?
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
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: UIControl.State.normal)
        
        if self.aspectConstraint != nil {
            self.contentImgView.removeConstraint(self.aspectConstraint!)
        }
        
        if let image = SDImageCache.shared.imageFromCache(forKey:self.viewModel?.fileUrl!) {
            
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
            
            self.mmPlayerLayer.thumbImageView.sd_setImage(with: URL(string: (self.viewModel?.fileUrl)!),
                                                          placeholderImage: UIImage(named: "img_item_placeholder")) {  (image, error, cacheType, url) in
                                                            
                                                            
                                                            if error != nil {
                                                                DispatchQueue.main.async {
                                                                    self.mmPlayerLayer.thumbImageView.image = UIImage(named: "img_item_placeholder")
                                                                }
                                                            }else{
                                                                SDImageCache.shared.store(image, forKey: (self.viewModel?.fileUrl)!, completion: {
                                                                    
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
        
        
        if (self.viewModel?.isVideo)! {
            self.mmPlayerLayer.playView = self.contentImgView
            mmPlayerLayer.replace(cover:  CoverView.instantiateFromNib())
            mmPlayerLayer.showCover(isShow: true)
            
            self.mmPlayerLayer.set(url: URL(string:(self.viewModel?.fileUrl!)!))
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
            self.contentImgView.image = UIImage(contentsOfFile: (self.viewModel?.fileUrl!)!)
        }
        
    }
    
    func setupRx(){
        self.captionTxtView.rx.text.orEmpty.bind(to: (viewModel?.captionText)!).disposed(by: self.disposeBag)
        
        self.viewModel?.onErrorTrigger
            .asDriver()
            .filter({$0.0 != ""})
            .drive(onNext : { arg in
                AlertDialog.shared.promptForWithoutObservable(title: arg.0, arg.1, actionTitle: "OK", vc: self)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.goBack.asDriver()
            .filter({$0})
            .drive(onNext : { _ in
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: self.disposeBag)
        
        self.sendBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.viewModel?.submit.accept(true)
            }).disposed(by:self.disposeBag)
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
