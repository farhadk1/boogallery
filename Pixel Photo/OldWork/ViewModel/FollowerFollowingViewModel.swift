//
//  FollowerFollowingViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 11/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

enum PROFILEMODE {
    case FOLLOWER
    case FOLLOWING
    case MENTIONEDFOLLOWER
    case LIKEUSER
    case CHAT
    case SEARCH
}

protocol FollowerFollowingViewModeling : BaseViewModelling , HasLoadmoreAndPulltoRefresh , HasGetProfile, NeedsToInitialize{
    var getUserFriend : BehaviorRelay<Bool> { get set }
    var userList: BehaviorRelay<[UserModel]> { get set }
    var userSelect:[UserModel] { get set }
    var type : PROFILEMODE { get set }
    
    func followUnfollowUser(user : UserModel)->Observable<Bool>
}

class FollowerFollowingViewModel: FollowerFollowingViewModeling {
    
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var userSelect: [UserModel] = []
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()
    
    var sdk = PixelPhotoSDK.shared
    
    var userID:Int?
    
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var offset: Int = 0
    var userList: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: .NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var getUserFriend: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var type : PROFILEMODE
    
    init(type : PROFILEMODE,userID:Int){
        self.type = type
        
        self.userID = userID
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest { (value) -> Driver<Bool> in
                if value == DATASTATUS.INITIAL {
                     return self.getUserFriend(state: value, hasTracker: true).asDriver(onErrorJustReturn: false)
                }
               return self.getUserFriend(state: value, hasTracker: false).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
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
    
    func getUserFriend(state:DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.userList.value[self.userList.value.count - 1].user_id!
        }
        
        if hasTracker {
            
            if self.type == PROFILEMODE.FOLLOWING || self.type == PROFILEMODE.MENTIONEDFOLLOWER {
                return (self.sdk.profileProvider.rx_getUserFollowing(userID:  self.userID!, offset: self.offset)
                    .trackActivity(self.indicator)
                    .observeOn(MainScheduler.instance)
                    .flatMapLatest({ (response) -> Observable<Bool> in
                        if response.code == "200" {
                            if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                                self.userList.accept(response.data!)
                                self.finishedPullToRefresh.accept(true)
                            }else if state == DATASTATUS.LOADMORE {
                                if response.data!.count > 0 {
                                    var temp = self.userList.value
                                    temp.append(contentsOf: response.data!)
                                    self.userList.accept(temp)
                                }else{
                                    
                                }
                                
                                self.finishedInfiniteScroll.accept(true)
                            }
                            
                            return Observable.just(true)
                        }
                        self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                        return Observable.just(false)
                    }))
            }else{
                return (self.sdk.profileProvider.rx_getUserFollower(userID: self.userID!, offset: self.offset)
                    .trackActivity(self.indicator)
                    .observeOn(MainScheduler.instance)
                    .flatMapLatest({ (response) -> Observable<Bool> in
                        if response.code == "200" {
                            if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                                self.userList.accept(response.data!)
                                self.finishedPullToRefresh.accept(true)
                            }else if state == DATASTATUS.LOADMORE {
                                if response.data!.count > 0 {
                                    var temp = self.userList.value
                                    temp.append(contentsOf: response.data!)
                                    self.userList.accept(temp)
                                }else{
                                    
                                }
                                
                                self.finishedInfiniteScroll.accept(true)
                            }
                            
                            return Observable.just(true)
                        }
                        self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                        return Observable.just(false)
                    }))
            }

        }
        
        if self.type == PROFILEMODE.FOLLOWING || self.type == PROFILEMODE.MENTIONEDFOLLOWER {
            return (self.sdk.profileProvider.rx_getUserFollowing(userID: self.userID!, offset: self.offset)
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.userList.accept(response.data!)
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                var temp = self.userList.value
                                temp.append(contentsOf: response.data!)
                                self.userList.accept(temp)
                                self.finishedPullToRefresh.accept(true)
                            }else{
                                // self.offset = self.notificationList.value[self.notificationList.value.count - 1].id!
                            }
                            
                            self.finishedInfiniteScroll.accept(true)
                        }
                        
                        return Observable.just(true)
                    }
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        
        return (self.sdk.profileProvider.rx_getUserFollower(userID: self.userID!, offset: self.offset)
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.userList.accept(response.data!)
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.userList.value
                            temp.append(contentsOf: response.data!)
                            self.userList.accept(temp)
                        }else{
                            
                        }
                        
                        self.finishedInfiniteScroll.accept(true)
                    }
                    
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))

    }
}
