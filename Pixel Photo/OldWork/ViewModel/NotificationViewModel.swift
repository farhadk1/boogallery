//
//  NotificationViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 03/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol NotificationViewModeling :
    BaseViewModelling,HasLoadmoreAndPulltoRefresh,NeedsToInitialize,HasGetProfile {
    var notificationList:  BehaviorRelay<[NotificationItem]> { get set }
    var notificationNum: BehaviorRelay<Int?> { get set }
    var messagesNum: BehaviorRelay<Int?> { get set }
    var showPost: BehaviorRelay<Int> { get set }
}

class NotificationViewModel: NotificationViewModeling {
    
    var showPost: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    var messagesNum: BehaviorRelay<Int?> = BehaviorRelay(value: 0)
    var notificationNum: BehaviorRelay<Int?> = BehaviorRelay(value: 0)
    var selectUserItem: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value:false)
    var notificationList: BehaviorRelay<[NotificationItem]> = BehaviorRelay(value: [])
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var offset: Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value:false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var sdk = PixelPhotoSDK.shared
    
    
    init() {

        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getNotifications(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getNotifications(state: value, hasTracker: false).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
    }
    
    func getNotifications(state : DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.notificationList.value[self.notificationList.value.count - 1].id!
        }
        
        if hasTracker {
            return (self.sdk.notificationProvider.rx_getNotification(userID: PixelPhotoSDK.shared.getMyUserID(), offset:self.offset)
                .catchError({ (error) -> Observable<GetNotificationResponse> in
                    return Observable.just(GetNotificationResponse(status: "400", message: error.localizedDescription))
                })
                .trackActivity(self.indicator)
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    
                    if response.code == "200" {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.notificationList.accept(response.data!)
                            self.notificationNum.accept(response.new_notifications!)
                            self.messagesNum.accept(response.new_messages!)
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                var temp = self.notificationList.value
                                temp.append(contentsOf: response.data!)
                                self.notificationList.accept(temp)
                            }
                            
                            self.notificationNum.accept(response.new_notifications!)
                            self.messagesNum.accept(response.new_messages!)
                            self.finishedInfiniteScroll.accept(true)
                        }
                        
                        return Observable.just(true)
                    }
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }))
        }
        
        return (self.sdk.notificationProvider.rx_getNotification(userID: PixelPhotoSDK.shared.getMyUserID(), offset:self.offset)
            .catchError({ (error) -> Observable<GetNotificationResponse> in
                return Observable.just(GetNotificationResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.notificationList.accept(response.data!)
                        self.notificationNum.accept(response.new_notifications!)
                        self.messagesNum.accept(response.new_messages!)
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.notificationList.value
                            temp.append(contentsOf: response.data!)
                            self.notificationList.accept(temp)
                        }
                        
                        self.notificationNum.accept(response.new_notifications!)
                        self.messagesNum.accept(response.new_messages!)
                        self.finishedInfiniteScroll.accept(true)
                    }
                    
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
}
