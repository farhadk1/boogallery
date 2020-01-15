//
//  ChatListViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 07/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol ChatListViewModeling : BaseViewModelling , NeedsToInitialize {
    var items : BehaviorRelay<[ChatItem]> { get set }
    var deleteUserChat : BehaviorRelay<ChatItem?> { get set }
   
}

class ChatListViewModel: ChatListViewModeling {
    
    var items: BehaviorRelay<[ChatItem]> = BehaviorRelay(value: [])
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var deleteUserChat : BehaviorRelay<ChatItem?> = BehaviorRelay(value: nil)
  

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
                return self.getChatList().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.deleteUserChat
            .asDriver()
            .filter({$0 != nil})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.removeChat(item: value!).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
    }
    

    func removeChat(item : ChatItem)->Observable<Bool>{
        return self.sdk.chatProvider.rx_deleteAllMessages(userID: "\(item.user_id!)")
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func getChatList()->Observable<Bool>{
        return self.sdk.chatProvider.rx_getChat()
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GetChatListResponse> in
                return Observable.just(GetChatListResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.items.accept(response.data!)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
}
