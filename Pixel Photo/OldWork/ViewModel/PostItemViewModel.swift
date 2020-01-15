//
//  PostItemViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 11/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol PostItemViewModeling: BaseViewModelling,
    HasGetComment,
    HasGetProfile,
    NeedsToInitialize,
    HasReportPost,
    ShouldGoBack,
    HasDeletePost{
    
    var item: BehaviorRelay<PostItem?> { get set }
    var getCommentsFromPostItem: BehaviorRelay<PostItem?> { get set }
    var getLikesFromPostItem: BehaviorRelay<PostItem?> { get set }
    var showAddPostMenu: BehaviorRelay<Bool> { get set }
    var sharePost: BehaviorRelay<PostItem?> { get set }
    var reloadDataTrig : BehaviorRelay<Bool> { get set }
    func addRemoveFavorite(postID:Int)->Observable<Bool>
    func likedUnlikPost(postID:Int)->Observable<Bool>
}

class PostItemViewModel: PostItemViewModeling {
    
    var getComment: BehaviorRelay<BehaviorRelay<PostItem?>?> = BehaviorRelay(value: nil)
    var deletePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var goBack: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var reloadDataTrig: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var reportPost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    
    
    var getCommentsFromPostItem: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var getLikesFromPostItem: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var showAddPostMenu: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var sharePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    
    
    var item: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var sdk = PixelPhotoSDK.shared
    
    var postID : Int?
    
    init(itemPost: PostItem) {
        
        self.item.accept(itemPost)
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.deletePost.asDriver()
            .filter({$0 != nil})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.deletePost(item: value!).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
    }
    
    init(item: BehaviorRelay<PostItem?>) {
        self.item = item
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.deletePost.asDriver()
            .filter({$0 != nil})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.deletePost(item: value!).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
    }
    
    init(id:Int) {
        self.postID = id
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (_) -> Driver<Bool> in
                return self.getPostByID().asDriver(onErrorJustReturn: false)
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
                    let item = self.item.value
                    if response.is_liked == 1 {
                        item?.is_liked = true
                        self.item.accept(item)
                        return Observable.just(true)
                    }else{
                         item?.is_liked = false
                        self.item.accept(item)
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
                     let item = self.item.value
                    if response.type == 1 {
                        item?.is_saved = true
                        self.item.accept(item)
                        return Observable.just(true)
                    }else{
                        item?.is_saved = false
                        self.item.accept(item)
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
    
    func getPostByID()->Observable<Bool>{
        return self.sdk.postProvider.rx_getPostByID(id: self.postID!)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GetPostByIDResponse> in
                return Observable.just(GetPostByIDResponse(status: "400", message: error.localizedDescription))
            })
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.item = BehaviorRelay(value: response.data!)
                    self.reloadDataTrig.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
        
}
