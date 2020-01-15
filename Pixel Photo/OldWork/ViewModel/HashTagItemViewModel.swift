//
//  HashTagItemViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 06/03/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol HashTagItemViewModeling :
    BaseViewModelling,
    HasGetComment,
    HasGetProfile,
    HasReportPost,
    HasDeletePost,
    ShouldGoBack {
    
    var searchHastag:BehaviorRelay<String> { get set }
    var searchMentioned:BehaviorRelay<String> { get set }
    var searchMentionedResult : BehaviorRelay<[UserModel]> { get set }
    var searchHashtag : BehaviorRelay<[PostItem]> { get set }
    var showPost: BehaviorRelay<BehaviorRelay<PostItem?>?> { get set }
    var sharePost: BehaviorRelay<PostItem?> { get set }
    var items: [PostItem]? { get set }
    var getLikesFromPostItem: BehaviorRelay<PostItem?> { get set }
    
    func addRemoveFavorite(postID:Int)->Observable<Bool>
    func likedUnlikPost(postID:Int)->Observable<Bool>
}

class HashTagItemViewModel: HashTagItemViewModeling {
    
     var showPost: BehaviorRelay<BehaviorRelay<PostItem?>?> = BehaviorRelay(value: nil)
    
    var searchHastag: BehaviorRelay<String> = BehaviorRelay(value: "")
    var searchMentioned: BehaviorRelay<String> = BehaviorRelay(value: "")
    var searchMentionedResult: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    var searchHashtag: BehaviorRelay<[PostItem]> = BehaviorRelay(value: [])
    
    var sharePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var getComment: BehaviorRelay<BehaviorRelay<PostItem?>?> = BehaviorRelay(value: nil)
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var reportPost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var deletePost: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    var goBack: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var getLikesFromPostItem: BehaviorRelay<PostItem?> = BehaviorRelay(value: nil)
    
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    let sdk = PixelPhotoSDK.shared
    var items: [PostItem]?
    
    init(items: [PostItem]) {
        self.items = items
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        
        self.searchHastag.asDriver()
            .filter({$0 != ""})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getSearchHashTags(query: value).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)

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
    
    func deletePost(item:PostItem)->Observable<Bool>{
        return (self.sdk.postProvider.rx_deleteMyPost(postID: item.post_id!)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    let tempItems = self.items!.filter { $0.post_id != item.post_id }
                    self.items = tempItems
                    //self.goBack.accept(true)
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

}
