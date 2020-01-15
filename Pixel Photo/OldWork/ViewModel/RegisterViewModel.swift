//
//  RegisterViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

class RegisterViewModel: RegisterViewModeling {
   
    
  
    
    
    var toEditPage: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var submitButton: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var usernameTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var emailText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var passwordText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var confirmPasswordText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
 var deviceId: BehaviorRelay<String> = BehaviorRelay(value: "")
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    var appdelegate = UIApplication.shared.delegate as? AppDelegate
    
    var sdk = PixelPhotoSDK.shared

    init() {
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.submitButton.asDriver()
            .filter({$0})
            .flatMapLatest({ (isClicked) -> Driver<Bool> in
                return self.register().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
    }
    
    func register() -> Observable<Bool>{
        return (self.sdk.authProvider.rx_registerUser(username: self.usernameTxt.value,
                                            password: self.passwordText.value,
                                            conf_password: self.confirmPasswordText.value,
                                            email: self.emailText.value, deviceId: appdelegate?.deviceId ?? "")
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.toEditPage.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
}
