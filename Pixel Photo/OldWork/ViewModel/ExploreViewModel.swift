//
//  ExploreViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 03/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol ExploreViewModeling :
    HasLoadmoreAndPulltoRefresh ,
    BaseViewModelling ,
    NeedsToInitialize ,
    HasGetProfile,
    HasDeletePost,
    ShouldGoBack {
    
    var userList: BehaviorRelay<[UserModel]> { get set }
    var exploreItems : BehaviorRelay<[PostItem]> { get set }
    var userDataState : BehaviorRelay<DATASTATUS> { get set }
    var finishedUserListInfiniteScroll: BehaviorRelay<Bool> { get set }
    var finishedUserListPullToRefresh: BehaviorRelay<Bool> { get set }
    var finishedInfiniteScroll : BehaviorRelay<Bool> { get set }
    var finishedPullToRefresh: BehaviorRelay<Bool> { get set }
    var showPost: BehaviorRelay<PostItem?> { get set }
    
     func followUnfollowUser(user : UserModel)->Observable<Bool>
}

class ExploreViewModel: ExploreViewModeling {
    
    var deletePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var goBack: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var showPost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var userDataState: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var finishedUserListInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedUserListPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var offset: Int = 0
    var userSuggestionOffset : Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: .NONE)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var exploreItems : BehaviorRelay<[PostItem]> = BehaviorRelay(value: [])
    var userList: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    private var sdk = PixelPhotoSDK.shared
    
    fileprivate var disposeBag = DisposeBag()
    
    init() {
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserSuggestions(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getExploreData(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getExploreData(state:value, hasTracker: false).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.userDataState.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserSuggestions(state:value, hasTracker: false).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.deletePost.asDriver()
            .filter({$0 != nil})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.deletePost(item: value!).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
    }
    
    func deletePost(item:PostItem)->Observable<Bool>{
        return (self.sdk.postProvider.rx_deleteMyPost(postID: item.post_id!)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    let tempItems = self.exploreItems.value.filter { $0.post_id != item.post_id }
                    self.exploreItems.accept(tempItems)
                    self.goBack.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func getExploreData(state : DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH || self.exploreItems.value.count == 0{
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.exploreItems.value[self.exploreItems.value.count - 1].post_id!
        }
        
        if hasTracker {
            return (self.sdk.postProvider.rx_getExploreData(offset: self.offset)
                .catchError({ (error) -> Observable<GetExploreResponse> in
                    return Observable.just(GetExploreResponse(status: "400", message: error.localizedDescription))
                })
                .trackActivity(self.indicator)
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL  || state == DATASTATUS.PULLTOREFRESH {
                            self.exploreItems.accept(response.data!)
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                var temp = self.exploreItems.value
                                temp.append(contentsOf: response.data!)
                                self.exploreItems.accept(temp)
                            }
                            self.finishedInfiniteScroll.accept(true)
                        }
                        
                        return Observable.just(true)
                    }
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        return (self.sdk.postProvider.rx_getExploreData(offset: self.offset)
            .catchError({ (error) -> Observable<GetExploreResponse> in
                return Observable.just(GetExploreResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    if state == DATASTATUS.INITIAL  || state == DATASTATUS.PULLTOREFRESH {
                        self.exploreItems.accept(response.data!)
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.exploreItems.value
                            temp.append(contentsOf: response.data!)
                            self.exploreItems.accept(temp)
                        }
                        self.finishedInfiniteScroll.accept(true)
                    }
                    
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
        
 
    }
    
    func getUserSuggestions(state : DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.userSuggestionOffset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.userSuggestionOffset = self.userList.value[self.userList.value.count - 1].user_id!
        }
        
        if hasTracker{
            return (self.sdk.profileProvider.rx_getSuggestedUsers(userIDParam: PixelPhotoSDK.shared.getMyUserID(),
                                                                  offsetParam: self.userSuggestionOffset,
                                                                  limitParam: 50)
                .catchError({ (error) -> Observable<GetUserSuggestionResponse> in
                    return Observable.just(GetUserSuggestionResponse(status: "400", message: error.localizedDescription))
                })
                .trackActivity(self.indicator)
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    
                    if response.code == "200" {
                        
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.userList.accept(response.data!)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                var temp = self.userList.value
                                temp.append(contentsOf: response.data!)
                                self.userList.accept(temp)
                            }else{

                            }
                        }
                        
                        return Observable.just(true)
                    }
                    
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        return (self.sdk.profileProvider.rx_getSuggestedUsers(userIDParam: sdk.getMyUserID(),offsetParam: self.userSuggestionOffset,limitParam: 50)
            .catchError({ (error) -> Observable<GetUserSuggestionResponse> in
                return Observable.just(GetUserSuggestionResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.userList.accept(response.data!)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.userList.value
                            temp.append(contentsOf: response.data!)
                            self.userList.accept(temp)
                        }else{

                        }
                    }
                    
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
}

