//
//  SearchViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 09/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoFramework
import RxCocoa
import RxSwift

enum SEARCHMODE {
    case USER
    case HASHTAG
    case NONE
}

protocol SearchViewModeling: BaseViewModelling {
    var hashItems : BehaviorRelay<[HashItem]> { get set }
    var userItems : BehaviorRelay<[UserModel]> { get set }
    var searchRandom : BehaviorRelay<Bool> { get set }
    var searchHashTagText : BehaviorRelay<String> { get set }
    var isSearching: Bool { get set }
    var mode : BehaviorRelay<SEARCHMODE> { get set }
    
    func followUnfollowUser(user : UserModel)->Observable<Bool>
}

class SearchViewModel: SearchViewModeling {
    
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var mode: BehaviorRelay<SEARCHMODE> = BehaviorRelay(value: SEARCHMODE.NONE)
    
    var searchHashTagText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var searchRandom: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var hashItems: BehaviorRelay<[HashItem]> = BehaviorRelay(value: [])
    var userItems: BehaviorRelay<[UserModel]> = BehaviorRelay(value:[])
    
    var hashTagOffset: Int = 0
    
    var isSearching:Bool = false

    let sdk = PixelPhotoSDK.shared
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    init() {
        
        self.mode.accept(SEARCHMODE.USER)
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.searchRandom
            .asDriver()
            .filter({$0})
            .flatMapLatest { (_) -> Driver<Bool> in
                return self.getSearchUserHashTags(query: "a").asDriver(onErrorJustReturn: true)
                
            }.drive(onNext : { _ in
                
            }).disposed(by: self.disposeBag)
        
        self.searchHashTagText
            .asDriver(onErrorJustReturn: "")
            .filter({$0 != ""})
            .flatMapLatest { (value) -> Driver<Bool> in
                
                if value == "" {
                    return self.getSearchUserHashTags(query: "a").asDriver(onErrorJustReturn: false)
                }
                return self.getSearchUserHashTags(query: value).asDriver(onErrorJustReturn: false)
                
            }.drive(onNext : { _ in
                
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
    
    func getSearchUserHashTags(query:String)->Observable<Bool>{
        return self.sdk.postProvider.rx_searchUserTag(word: query, offset: self.hashTagOffset)
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GetSearchUserTagResponse> in
                return Observable.just(GetSearchUserTagResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.hashItems.accept((response.data?.hash!)!)
                    self.userItems.accept((response.data?.users!)!)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    


}
