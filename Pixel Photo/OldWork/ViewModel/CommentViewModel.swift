//
//  CommentViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 21/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol CommentViewModeling : NeedsToInitialize,
    BaseViewModelling,
    HasLoadmoreAndPulltoRefresh,
    HasGetProfile{
    
    var commentItems : [CommentItem]  { get set }
    var commentText : BehaviorRelay<String>  { get set }
    var sendCommentTrigger : BehaviorRelay<Bool>  { get set }
     var reloadData : BehaviorRelay<Bool>  { get set }
}

class CommentViewModel: CommentViewModeling {
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    
    var reloadData: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var offset: Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var commentText : BehaviorRelay<String> = BehaviorRelay(value: "")
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var sendCommentTrigger : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    var item : BehaviorRelay<PostItem?>
    
    var sdk = PixelPhotoSDK.shared
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var commentItems : [CommentItem] = []
    
    init(item : BehaviorRelay<PostItem?>) {
        
        self.item = item
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getCommentFromPostID(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getCommentFromPostID(state: value, hasTracker: false).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.sendCommentTrigger
            .asDriver()
            .filter({$0})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.sendCommentToPostID().asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
    }
    
    func sendCommentToPostID()->Observable<Bool>{
        return (self.sdk.postProvider.rx_addNewComment(postID: (self.item.value?.post_id!)!, commentTxt: self.commentText.value)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    
                    let tempItem = self.item.value
                    let item = CommentItem(postID: (self.item.value!.post_id!), text: self.commentText.value, time: "1 sec ago", avatar: PixelPhotoSDK.shared.userDefaultHelper.getProfileImageUrl())
                    item.username = "Me"
                    self.commentItems.insert(item, at: 0)
                    tempItem?.comments? = self.commentItems
                    self.item.accept(tempItem)
                    
                    self.reloadData.accept(true)
                    self.commentText.accept("")
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func getCommentFromPostID(state : DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.commentItems = []
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.commentItems[self.commentItems.count - 1].post_id!
        }
        
        if hasTracker {
            return (self.sdk.postProvider.rx_getCommentPost(postID: (self.item.value!.post_id!), offset: self.offset)
                .catchError({ (error) -> Observable<GetCommentResponse> in
                    return Observable.just(GetCommentResponse(status: "400", message: error.localizedDescription))
                })
                .trackActivity(self.indicator)
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.commentItems = response.data!
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            
                            if response.data!.count > 0 {
                                var temp = self.commentItems
                                temp.append(contentsOf: response.data!)
                                self.commentItems.append(contentsOf: temp)
                            }
                            
                            self.finishedInfiniteScroll.accept(true)
                        }
                        
                        return Observable.just(true)
                    }
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }else{
            return (self.sdk.postProvider.rx_getCommentPost(postID: (self.item.value!.post_id!), offset: self.offset)
                .catchError({ (error) -> Observable<GetCommentResponse> in
                    return Observable.just(GetCommentResponse(status: "400", message: error.localizedDescription))
                })
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.commentItems = response.data!
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            
                            if response.data!.count > 0 {
                                var temp = self.commentItems
                                temp.append(contentsOf: response.data!)
                                self.commentItems.append(contentsOf: temp)
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
}
