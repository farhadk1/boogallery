//
//  PPStoryVideoSubmitViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 12/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import MMPlayerView
import RxSwift
import RxCocoa
import AVFoundation
import SDWebImage

class PPStoryVideoSubmitViewController: UIViewController {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var captionTxtView: UITextView!
    @IBOutlet weak var contentImgView: UIImageView!
    
    var disposeBag = DisposeBag()
    
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
//        setupRx()
    }
    
    func setupUI(){
        
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
//    private func createStory(){
//        self.showProgressDialog(text: "Loading...")
//        let accessToken = AppInstance.instance.accessToken ?? ""
//
//
//        Async.background({
//            if self.avatarImage == nil{
//                ProfileManger.instance.updateUserProfile(accessToken: accessToken, firstname: firstname, lastname: lastname, gender: gender, about: about, facebook: facebook, google: google, avatar_data: nil, completionBlock: { (success, sessionError, error) in
//                    if success != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.debug("success = \(success?.message ?? "")")
//                                self.view.makeToast(success?.message ?? "")
//                                AppInstance.instance.fetchUserProfile()
//                                let vc = R.storyboard.profile.userSuggestionVC()
//                                self.navigationController?.pushViewController(vc!, animated: true)
//                            }
//
//                        })
//                    }else if sessionError != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.error("sessionError = \(sessionError?.errors?.errorText)")
//                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
//                            }
//
//                        })
//
//
//                    }else {
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.error("error = \(error?.localizedDescription)")
//                                self.view.makeToast(error?.localizedDescription ?? "")
//                            }
//
//                        })
//
//                    }
//                })
//            }else{
//                let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
//                ProfileManger.instance.updateUserProfile(accessToken: accessToken, firstname: firstname, lastname: lastname, gender: gender, about: about, facebook: facebook, google: google, avatar_data: avatarData, completionBlock: { (success, sessionError, error) in
//                    if success != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.debug("success = \(success?.message ?? "")")
//                                self.view.makeToast(success?.message ?? "")
//                                AppInstance.instance.fetchUserProfile()
//                            }
//
//                        })
//                    }else if sessionError != nil{
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.error("sessionError = \(sessionError?.errors?.errorText)")
//                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
//                            }
//
//                        })
//
//
//                    }else {
//                        Async.main({
//                            self.dismissProgressDialog {
//                                log.error("error = \(error?.localizedDescription)")
//                                self.view.makeToast(error?.localizedDescription ?? "")
//                            }
//
//                        })
//
//                    }
//                })
//            }
//
//        })
//
//
//    }
    
    
}
