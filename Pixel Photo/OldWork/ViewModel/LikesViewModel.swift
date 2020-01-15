//
//  LikesViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol LikesViewModeling: NeedsToInitialize, BaseViewModelling, HasLoadmoreAndPulltoRefresh,HasGetProfile {
    var userList : [LikesItem] { get set }
    
    func followUnfollowUser(user : UserModel)->Observable<Bool>
}

class LikesViewModel: LikesViewModeling {
    
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var offset: Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var commentText : BehaviorRelay<String> = BehaviorRelay(value: "")
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var sendCommentTrigger : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    var postID:Int?

    
    var userList : [LikesItem] = []
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var sdk = PixelPhotoSDK.shared
    

    init(postID:Int) {
        
        self.postID = postID
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapFirst({ (value) -> Driver<Bool> in
                return self.getLikesFromPost(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapFirst({ (value) -> Driver<Bool> in
                return self.getLikesFromPost(state: value, hasTracker: false).asDriver(onErrorJustReturn: false)
            })
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
    
    func getLikesFromPost(state:DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.userList[self.userList.count - 1].user_id!
        }
        
        if hasTracker {
            return (self.sdk.postProvider.rx_getLikes(postID: "\(self.postID!)", offset: "\(self.offset)")
                .trackActivity(self.indicator)
                .catchError({ (error) -> Observable<GetPostLikesResponse> in
                    return Observable.just(GetPostLikesResponse(status: "400", message: error.localizedDescription))
                })
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.userList = response.data!
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            
                            if response.data!.count > 0 {
                                var temp = self.userList
                                temp.append(contentsOf: response.data!)
                                self.userList.append(contentsOf: temp)
                            }
                            
                            self.finishedInfiniteScroll.accept(true)
                        }
                        
                        return Observable.just(true)
                    }
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        return (self.sdk.postProvider.rx_getLikes(postID: "\(self.postID!)", offset: "\(self.offset)")
            .catchError({ (error) -> Observable<GetPostLikesResponse> in
                return Observable.just(GetPostLikesResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.userList = response.data!
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        
                        if response.data!.count > 0 {
                            var temp = self.userList
                            temp.append(contentsOf: response.data!)
                            self.userList.append(contentsOf: temp)
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
