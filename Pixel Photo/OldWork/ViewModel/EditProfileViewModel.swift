//
//  EditProfileViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

class EditProfileViewModel:EditProfileViewModeling {
    
    var fnameTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var lnameTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var aboutTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var genderTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var fbUrlTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var googleUrlTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var submitButton: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var profileImage : BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    var profileUrl : BehaviorRelay<String> = BehaviorRelay(value: "")
    var goToSuggestionUserPage : BehaviorRelay<Bool> = BehaviorRelay(value: false)

    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()
    
    var sdk = PixelPhotoSDK.shared
    var user : UserModel?
    var mode : EDITPROFILEMODE?

    init(mode : EDITPROFILEMODE?) {
        
        self.mode = mode
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.submitButton.asDriver()
            .filter({$0})
            .flatMapLatest({ (isClicked) -> Driver<Bool> in
                return self.submit().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
    }
    
    init(user : UserModel,mode : EDITPROFILEMODE?) {
        self.mode = mode
        self.user = user
        
//        self.fnameTxt.accept(user.fname!)
//        self.lnameTxt.accept(user.lname!)
//        self.aboutTxt.accept(user.about!)
//        self.genderTxt.accept(user.gender!)
        
        print(user.avatar!)
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.submitButton.asDriver()
            .filter({$0})
            .flatMapLatest({ (isClicked) -> Driver<Bool> in
                return self.submit().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
    }
    
    func submit()->Observable<Bool>{
        
        var profileUrl:String? = self.profileUrl.value
        var gender:String? = self.genderTxt.value
        var fname:String? = self.fnameTxt.value
        var lname:String? = self.lnameTxt.value
        var about:String? = self.aboutTxt.value
        var fb:String? = self.fbUrlTxt.value
        var google:String? = self.googleUrlTxt.value

        if profileUrl!.lowercased().contains("http") || profileUrl == "" { profileUrl = nil }
        if self.genderTxt.value == "" { gender = nil }
        if self.fnameTxt.value == "" { fname = nil }
        if self.lnameTxt.value == "" { lname = nil }
        if self.aboutTxt.value == "" { about = nil }
        if self.fbUrlTxt.value == "" { fb = nil } else { fb = "https://www.facebook.com/" + fb! }
        if self.googleUrlTxt.value == "" { google = nil } else { google = "https://plus.google.com/u/0/" + google! }
        
        return (self.sdk.profileProvider.editProfileInfo(gender: gender,
                                                         fname: fname,
                                                         lname: lname,
                                                         about: about,
                                                         facebookUrl: fb,
                                                         googleUrl: google,
                                                         avatar: profileUrl)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.goToSuggestionUserPage.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
}
 
