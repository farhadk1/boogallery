//
//  HomeViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 03/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol HomeViewModeling :
    HasLoadmoreAndPulltoRefresh,
    BaseViewModelling ,
    NeedsToInitialize,
    HasGetComment,
    HasGetProfile,
    HasReportPost,
    HasDeletePost,
    ShouldGoBack{
    
     var notificationNum: BehaviorRelay<Int?> { get set }
    var searchHastag:BehaviorRelay<String> { get set }
    var searchMentioned:BehaviorRelay<String> { get set }
    var searchMentionedResult : BehaviorRelay<[UserModel]> { get set }
    var searchHashtag : BehaviorRelay<[PostItem]> { get set }
    
    var storiesItems : BehaviorRelay<[StoryItem]> { get set }
    var postItems : [PostItem] { get set }
    var userItem : BehaviorRelay<UserModel?> { get set }
    var getLikesFromPostItem: BehaviorRelay<PostItem?> { get set }
    var showAddPostMenu: BehaviorRelay<Bool> { get set }
    var showPost: BehaviorRelay<BehaviorRelay<PostItem?>?> { get set }
    var sharePost: BehaviorRelay<PostItem?> { get set }
    var refreshStories: BehaviorRelay<Bool> { get set }
    var shouldRefresh: BehaviorRelay<Bool> { get set }
    var pressOtherPages: BehaviorRelay<Bool> { get set }
    
    func addRemoveFavorite(postID:Int)->Observable<Bool>
    func likedUnlikPost(postID:Int)->Observable<Bool>
   
}

class HomeViewModel: HomeViewModeling {
    
    var notificationNum: BehaviorRelay<Int?> = BehaviorRelay(value: 0)
    
    var pressOtherPages: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var searchHastag: BehaviorRelay<String> = BehaviorRelay(value: "")
    var searchMentioned: BehaviorRelay<String> = BehaviorRelay(value: "")
    var searchMentionedResult : BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    var searchHashtag : BehaviorRelay<[PostItem]> = BehaviorRelay(value: [])
    
    var refreshStories: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var getComment: BehaviorRelay<BehaviorRelay<PostItem?>?> = BehaviorRelay(value: nil)
    var shouldRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var showPost: BehaviorRelay<BehaviorRelay<PostItem?>?> = BehaviorRelay(value: nil)
    var goBack: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var deletePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var sharePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var showAddPostMenu: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var reportPost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var postItems: [PostItem] = []
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var getLikesFromPostItem: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var userItem: BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var offset: Int = 0
    var offsetPost : String = ""
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: .NONE)
    var storiesItems : BehaviorRelay<[StoryItem]> = BehaviorRelay(value: [])
    
    var sdk = PixelPhotoSDK.shared
    
    fileprivate var disposeBag = DisposeBag()

    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    init() {
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getUserData().asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getStories(hasTracker: false).asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getHomePost(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getNotifications().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 == DATASTATUS.LOADMORE})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getHomePost(state: value, hasTracker: false).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 == DATASTATUS.PULLTOREFRESH})
            .flatMapLatest { (value) -> Driver<DATASTATUS> in
                return self.getHomePost(state: value, hasTracker: false).asDriver(onErrorJustReturn: false)
                    .map { _ in
                        return value
                }
            }
            .flatMapLatest({ (value) -> Driver<DATASTATUS> in
                return self.getStories(hasTracker: false).asDriver(onErrorJustReturn: false)
                    .map{  _ in
                        return value
                }
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        
        self.reportPost.asDriver()
            .filter({$0 != nil})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.reportPost(item: (value?.post_id!)!).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.deletePost.asDriver()
            .filter({$0 != nil})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.deletePost(item: value!).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.refreshStories.asDriver()
            .filter({$0 != false})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getStories(hasTracker: false).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.searchHastag.asDriver()
            .filter({$0 != ""})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getSearchHashTags(query: value).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.searchMentioned.asDriver()
            .filter({$0 != ""})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getSearchMentionedContactsTags(query: value).asDriver(onErrorJustReturn: false)
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
                    let tempItems = self.postItems.filter { $0.post_id != item.post_id }
                    self.postItems = tempItems
                    self.goBack.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func likedUnlikPost(postID:Int)->Observable<Bool>{
        return (self.sdk.postProvider.rx_likeUnlikePost(postID: postID)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    if response.is_liked == 1 {
                        return Observable.just(true)
                    }else{
                        return Observable.just(false)
                    }
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func addRemoveFavorite(postID:Int)->Observable<Bool>{
        return (self.sdk.postProvider.rx_addRemoveFavorite(postID: postID)
            .catchError({ (error) -> Observable<AddRemoveFavoriteResponse> in
                return Observable.just(AddRemoveFavoriteResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
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
    
    func reportPost(item:Int)->Observable<Bool>{
        return (self.sdk.postProvider.rx_reportPost(postID: item)
            .trackActivity(self.indicator)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.onErrorTrigger.accept(((response.status)!,(response.message)!))
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func getStories(hasTracker:Bool)->Observable<Bool>{
        if hasTracker {
            return (self.sdk.storiesProvider.rx_getStores()
                .trackActivity(self.indicator)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    if response.code == "200" {
                        self.storiesItems.accept(response.data!)
                        self.finishedPullToRefresh.accept(true)
                        return Observable.just(true)
                    }
                    self.finishedPullToRefresh.accept(true)
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        return (self.sdk.storiesProvider.rx_getStores()
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.storiesItems.accept(response.data!)
                    self.finishedPullToRefresh.accept(true)
                    return Observable.just(true)
                }
                self.finishedPullToRefresh.accept(true)
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))

    }
    
    func getSearchHashTags(query:String)->Observable<Bool>{
        return self.sdk.postProvider.rx_getHastTagPost(hastTag: query, offset: 0, limit: 50)
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GetHastTagResponse> in
                return Observable.just(GetHastTagResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.searchHashtag.accept(response.data!)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func getSearchMentionedContactsTags(query:String)->Observable<Bool>{
        return self.sdk.postProvider.rx_searchUserTag(word: query, offset: 0)
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GetSearchUserTagResponse> in
                return Observable.just(GetSearchUserTagResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.searchMentionedResult.accept((response.data?.users!)!)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func getUserData()->Observable<Bool>{
        return (self.sdk.profileProvider.rx_getUserData(userID: "\(sdk.getMyUserID)")
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
    
    func getHomePost(state : DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
           self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.postItems[self.postItems.count - 1].post_id!
        }
        
        if hasTracker {
            return (self.sdk.postProvider.rx_getHomeData(offset:self.offset)
                .trackActivity(self.indicator)
                .catchError({ (error) -> Observable<GetHomeResponse> in
                    return Observable.just(GetHomeResponse(status: "400", message: error.localizedDescription))
                })
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.postItems = response.data!
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                self.postItems += response.data!
                            }
                            
                            self.finishedInfiniteScroll.accept(true)
                        }
                        
                        return Observable.just(true)
                    }
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        return (self.sdk.postProvider.rx_getHomeData(offset: self.offset)
            .catchError({ (error) -> Observable<GetHomeResponse> in
                return Observable.just(GetHomeResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                         self.postItems = response.data!
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                             self.postItems += response.data!
                        }else{
                            self.offset = self.offset - 1
                        }
                        self.finishedInfiniteScroll.accept(true)
                    }
                    
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func getNotifications()->Observable<Bool>{
        return (self.sdk.notificationProvider.rx_getNotification(userID: PixelPhotoSDK.shared.getMyUserID(), offset:0)
            .catchError({ (error) -> Observable<GetNotificationResponse> in
                return Observable.just(GetNotificationResponse(status: "400", message: error.localizedDescription))
            })
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.notificationNum.accept(response.new_notifications!)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
}
