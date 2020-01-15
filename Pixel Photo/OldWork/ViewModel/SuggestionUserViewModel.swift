
//
//  SuggestionUserViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 03/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

class SuggestionUserViewModel: SuggestionUserViewModeling {
    
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var offset: Int = 0
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()
    
    var getUserSuggestion: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var userList: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    var sdk = PixelPhotoSDK.shared
    
    init(){
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getUserSuggestions(state: value).asDriver(onErrorJustReturn: false)
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
    
    func getUserSuggestions(state : DATASTATUS)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.userList.value[self.userList.value.count - 1].user_id! 
        }
        
        return (self.sdk.profileProvider.rx_getSuggestedUsers(userIDParam: PixelPhotoSDK.shared.getMyUserID(),offsetParam: self.offset, limitParam: 50)
            .catchError({ (error) -> Observable<GetUserSuggestionResponse> in
                return Observable.just(GetUserSuggestionResponse(status: "400", message: error.localizedDescription))
            })
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    
                    if state == DATASTATUS.INITIAL {
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
