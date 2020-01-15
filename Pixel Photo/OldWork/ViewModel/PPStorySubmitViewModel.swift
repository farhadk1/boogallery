//
//  PPStorySubmitViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol PPStorySubmitViewModeling : BaseViewModelling {
    var captionText : BehaviorRelay<String> { get set }
    var goBack: BehaviorRelay<Bool> { get set }
    var submit: BehaviorRelay<Bool> { get set }
    var fileUrl:String? { get set }
    var isVideo:Bool? { get set }
}

class PPStorySubmitViewModel: PPStorySubmitViewModeling {
    var submit: BehaviorRelay<Bool> = BehaviorRelay(value:false)
    var goBack: BehaviorRelay<Bool> = BehaviorRelay(value:false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var sdk = PixelPhotoSDK.shared
    var fileUrl:String?
    var isVideo:Bool?
    
    var captionText : BehaviorRelay<String> = BehaviorRelay(value: "")
    
    init(fileUrl:String,isVideo:Bool) {
        
        self.fileUrl = fileUrl
        self.isVideo = isVideo
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.submit
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.createPost().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
    }
    
    func createPost()->Observable<Bool>{
        return self.sdk.postProvider.rx_createStory(fileUrl: self.fileUrl!, isVideo: self.isVideo!, caption: self.captionText.value)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<PostStoryResponse> in
                return Observable.just(PostStoryResponse(status: "400", message: error.localizedDescription))
            })
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.goBack.accept(true)
                    return Observable.just(true)
                }else{
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }
            })
    }
}
