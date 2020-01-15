//
//  ForgotPasswordViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

class ForgotPasswordViewModel: ForgotPasswordModeling {

    var submitButton: BehaviorRelay<Bool>  = BehaviorRelay(value: false)
    var emailText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))

    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    fileprivate var sdk = PixelPhotoSDK.shared
    
    init() {
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.submitButton.asDriver()
            .filter({$0})
            .flatMapLatest({ (isClicked) -> Driver<Bool> in
                return self.forgotPassword().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
    }
    
    func forgotPassword()->Observable<Bool>{
        return (self.sdk.authProvider.rx_forgotPassword(email: self.emailText.value)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    return Observable.just(true)
                }
               self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
        
    }
}
