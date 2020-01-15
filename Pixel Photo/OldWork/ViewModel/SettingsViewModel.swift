//
//  SettingsViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 23/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework


protocol SettingsViewModeling : BaseViewModelling , NeedsToInitialize {
    
    var user:BehaviorRelay<UserModel?> { get set }
    
    var submit : BehaviorRelay<Bool> { get set }
    
    var genderText: BehaviorRelay<String> { get set }
    var emailText: BehaviorRelay<String> { get set }
    var userNameText: BehaviorRelay<String> { get set }
    var fbText: BehaviorRelay<String> { get set }
    var googleText: BehaviorRelay<String> { get set }
    
    var currentPasswordText: BehaviorRelay<String> { get set }
    var newPasswordText: BehaviorRelay<String> { get set }
    var rePasswordText: BehaviorRelay<String> { get set }
    
    var notificationLike:BehaviorRelay<Int?> { get set }
    var notificationComment:BehaviorRelay<Int?> { get set }
    var notificationFollow:BehaviorRelay<Int?> { get set }
    var notificationMention:BehaviorRelay<Int?> { get set }
    
    var privacyProfile:BehaviorRelay<Int?> { get set }
    var privacyMessages:BehaviorRelay<Int?> { get set }
    var privacySearchEngine:BehaviorRelay<Int?> { get set }
    
    var blockedUsers : BehaviorRelay<[UserModel]> { get set }
    
    var blockUnblockUser : BehaviorRelay<UserModel?> { get set }
    
    var logout:BehaviorRelay<Bool> { get set }
}

class SettingsViewModel : SettingsViewModeling {

    
    var blockUnblockUser: BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var privacySearchEngine: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    var privacyProfile: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    var privacyMessages: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    
    var notificationLike: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    var notificationComment: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    var notificationFollow: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    var notificationMention: BehaviorRelay<Int?> = BehaviorRelay(value: -1)
    
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    var user:BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var submit:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var logout:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()
    
    var genderText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var emailText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var userNameText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var fbText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var googleText: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var currentPasswordText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var newPasswordText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var rePasswordText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var pageType:SETTINGPAGE?
    
    var initialize = false
    
    var blockedUsers : BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    
    var sdk = PixelPhotoSDK.shared
    
    init(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE) {

        self.user = user
        
        self.pageType = pageType
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
    
        if self.pageType == SETTINGPAGE.GENERAL {
            self.emailText.accept((user.value?.email)!)
            self.userNameText.accept((user.value?.uname)!)
            self.genderText.accept((user.value?.gender?.capitalizingFirstLetter())!)
            self.fbText.accept((user.value?.facebook)!)
            self.googleText.accept((user.value?.google)!)
        }else if self.pageType == SETTINGPAGE.NOTIFICATION {
            self.notificationLike.accept(Int((user.value?.n_on_like)!))
            self.notificationComment.accept(Int((user.value?.n_on_comment)!))
            self.notificationFollow.accept(Int((user.value?.n_on_follow)!))
            self.notificationMention.accept(Int((user.value?.n_on_mention)!))
        }else if self.pageType == SETTINGPAGE.ACCOUNTPRIVACY {
            self.privacyProfile.accept(Int((user.value?.p_privacy)!))
            self.privacyMessages.accept(Int((user.value?.c_privacy)!))
            self.privacySearchEngine.accept(Int((user.value?.search_engines)!))
        }
        
        if self.pageType == SETTINGPAGE.BLOCKEDUSER {
            self.isInitialize
                .asDriver()
                .filter({_ in self.initialize != false})
                .flatMapLatest { (value) -> Driver<Bool> in
                    return self.getblockUser().asDriver(onErrorJustReturn: false)
                }
                .drive(onNext : { _ in
                    
                }).disposed(by: self.disposeBag)
        }

        self.privacySearchEngine
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updatePrivacy().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.privacyMessages
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updatePrivacy().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.privacyProfile
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updatePrivacy().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)

        self.notificationMention
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updateNotification().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.notificationComment
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updateNotification().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.notificationFollow
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updateNotification().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.notificationLike
            .asDriver()
            .filter({_ in self.initialize != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.updateNotification().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.submit.asDriver()
            .filter({$0})
            .flatMapLatest({ (_) -> Driver<Bool> in
                if self.pageType == SETTINGPAGE.GENERAL {
                    return self.updateGeneralInfo().asDriver(onErrorJustReturn: false)
                }else if self.pageType == SETTINGPAGE.CHANGEPASSWORD {
                    return self.updatePassword().asDriver(onErrorJustReturn: false)
                }
                return self.deleteAccount().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.blockUnblockUser
            .asDriver()
            .filter({$0 != nil})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.blockUnblockUser(item: value!).asDriver(onErrorJustReturn: true)
            })
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.initialize = true
    }
    
    func blockUnblockUser(item:UserModel)->Observable<Bool>{
        return self.sdk.profileProvider.rx_blockUnBlockUser(userID: item.user_id!)
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    return self.getblockUser()
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func getblockUser()->Observable<Bool>{
        return self.sdk.profileProvider.rx_getBlockedUser()
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.blockedUsers.accept(response.data!)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }

    
    func updatePrivacy()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_updatePrivacy(privacyProfile: self.privacyProfile.value,
                                                          privacyMessage: self.privacyMessages.value,
                                                          searchEnginePrivacy: self.privacySearchEngine.value!)
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }

    
    func updateNotification()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_updateNotification(likeNotification: self.notificationLike.value!, commentNotification: self.notificationComment.value!, followNotification: self.notificationFollow.value!, mentionNotification: self.notificationMention.value!)
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    let temp = self.user.value
                    temp?.n_on_like = String(self.notificationLike.value!)
                    temp?.n_on_follow = String(self.notificationFollow.value!)
                    temp?.n_on_comment = String(self.notificationComment.value!)
                    temp?.n_on_mention = String(self.notificationMention.value!)
                    self.user.accept(temp)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }

    func updatePassword()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_updatePassword(currentPassword: self.currentPasswordText.value, newPassword: self.newPasswordText.value, reTypePassword: self.rePasswordText.value)
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.onErrorTrigger.accept(("Update Profile",(response.message)!))
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func deleteAccount()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_deleteMyAccount(password: self.currentPasswordText.value)
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.logout.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }

    func updateGeneralInfo()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_updateGeneralInfo(userName: self.userNameText.value, email: self.emailText.value, gender: self.genderText.value, fbUrl: self.fbText.value,googleUrl: self.googleText.value)
            .observeOn(MainScheduler.instance)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    let temp = self.user.value
                    temp?.username = self.userNameText.value
                    temp?.email = self.emailText.value
                    temp?.gender = self.genderText.value
                    self.user.accept(temp)
                    self.onErrorTrigger.accept(("Update Profile",(response.message)!))
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    
}
