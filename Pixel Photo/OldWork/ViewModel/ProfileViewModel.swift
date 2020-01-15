//
//  MyProfileViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 03/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol ProfileViewModeling :
    HasLoadmoreAndPulltoRefresh ,
    BaseViewModelling,
    NeedsToInitialize,
    ShouldGoBack{
    
    var userItem : BehaviorRelay<UserModel?> { get set }
    var postItems : BehaviorRelay<[PostItem]> { get set }
    var userPostResponseData : GetUserPostResponse? { get set }
    var messageuser : BehaviorRelay<UserModel?> { get set }
    var showPost: BehaviorRelay<PostItem?> { get set }
    var blockUser: BehaviorRelay<Bool> { get set }
    var userID:Int? { get set }
    var profileUrl : BehaviorRelay<String> { get set }
    var profileImage : BehaviorRelay<UIImage?> { get set }
    var showImageMenu : BehaviorRelay<Bool> { get set }
    
    func followUnfollowUser(user : UserModel)->Observable<Bool>
}

class ProfileViewModel: ProfileViewModeling {
    
    var showImageMenu: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var profileImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    var profileUrl: BehaviorRelay<String> = BehaviorRelay(value: "")
    var blockUser: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var goBack: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var showPost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var messageuser: BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var userItem: BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var offset: Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var user : BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var postItems : BehaviorRelay<[PostItem]> = BehaviorRelay(value: [])
    
    var userPostResponseData : GetUserPostResponse?
    
    var sdk = PixelPhotoSDK.shared
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()

    var userID:Int?
  
    init(userID:Int) {
        
        self.userID = userID
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserPost().asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserData().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserPost().asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserData().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.blockUser.asDriver()
            .filter({ $0 != false })
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.blockUserObs().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.profileUrl
            .asDriver()
            .filter({$0 != ""})
            .flatMapLatest({ (url) -> Driver<Bool> in
                return self.uploadProfilePhoto(url: url).asDriver(onErrorJustReturn: true)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
    }
    
    func uploadProfilePhoto(url:String)->Observable<Bool>{
        return (self.sdk.profileProvider.uploadProfilePhoto(avatar: url)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) ->  Observable<Bool> in
                
                if response.code == "200" {
                    self.goBack.accept(true)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func blockUserObs()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_blockUnBlockUser(userID: self.userID!)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) ->  Observable<Bool> in
                
                if response.code == "200" {
                    self.goBack.accept(true)
                    return Observable.just(true)
                }
               
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func followUnfollowUser(user : UserModel)->Observable<Bool>{
        return (self.sdk.profileProvider.rx_followUnfollowUser(userIDParam: user.user_id!)
            .catchError({ (error) -> Observable<FollowUnfollowUserResponse> in
                return Observable.just(FollowUnfollowUserResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) ->  Observable<Bool> in
                if response.code == "200" {
                    if response.type == 1 {
                        return Observable.just(true)
                    }else{
                        return Observable.just(false)
                    }
                }

                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func getUserData()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_getUserData(userID: "\(self.userID!)")
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GetUserDataResponse> in
                return Observable.just(GetUserDataResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.userItem.accept(response.data!)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func getUserPost()->Observable<Bool>{
        return (self.sdk.postProvider.rx_getPostFromUser(userID: "\(self.userID!)")
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GetUserPostResponse> in
                return Observable.just(GetUserPostResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.userPostResponseData = response
                    self.postItems.accept((response.data?.user_posts!)!)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
   
}
