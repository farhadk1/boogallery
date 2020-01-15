//
//  LoginViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

class LoginViewModel: LoginViewModeling {

    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    fileprivate var disposeBag = DisposeBag()
    
    var toDashboard: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var toEditPage: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var googleCred: BehaviorRelay<(String)> = BehaviorRelay(value: "")
    var userNameText : BehaviorRelay<String> = BehaviorRelay(value: "")
    var passwordText : BehaviorRelay<String> = BehaviorRelay(value: "")
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var fbCred: BehaviorRelay<(String)> = BehaviorRelay(value: (""))
    var submitButton : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var deviceId: BehaviorRelay<String> = BehaviorRelay(value: "")
    let appdelegate = UIApplication.shared.delegate as? AppDelegate
    
    var sdk = PixelPhotoSDK.shared
    
    init() {
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.submitButton.asDriver()
            .filter({$0})
            .flatMapLatest({ (isClicked) -> Driver<Bool> in
                return self.loginUser().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.fbCred.asDriver()
            .filter({$0 != ""})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.authSocial(type: "facebook", socialCred: value).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.googleCred.asDriver()
            .filter({$0 != ""})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.authSocial(type: "google", socialCred: value).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
    }
    
    func loginUser()->Observable<Bool>{
        return (self.sdk.authProvider.rx_loginUser(email: self.userNameText.value, password: self.passwordText.value, device_id: appdelegate?.deviceId ?? "")
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.toDashboard.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func authSocial(type:String,socialCred:String)->Observable<Bool>{
        return (self.sdk.authProvider.rx_authSocialUser(provider: type, socialAccessToken: socialCred)
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
