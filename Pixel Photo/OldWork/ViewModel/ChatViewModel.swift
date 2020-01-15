//
//  ChatViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 07/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol ChatViewModeling:  BaseViewModelling , NeedsToInitialize  {
    var messageTxt: BehaviorRelay<String> { get set }
    var messages : BehaviorRelay<[MessageItem]> { get set }
    var blockUnblockUser : BehaviorRelay<Bool> { get set }
    var goBack : BehaviorRelay<Bool> { get set }
    var clearMessagesTrig : BehaviorRelay<Bool> { get set }
    var cleanText : BehaviorRelay<Bool> { get set }
    var user : UserModel? { get set }
    var sendMessage : BehaviorRelay<Bool> { get set }
    var deleteMessageItem : BehaviorRelay<MessageItem?> { get set }
    
    var isBlocked:Bool { get set }
}

class ChatViewModel: ChatViewModeling {
    
    var deleteMessageItem : BehaviorRelay<MessageItem?> = BehaviorRelay(value: nil)
    var cleanText : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var clearMessagesTrig : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var blockUnblockUser : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var messageTxt: BehaviorRelay<String> = BehaviorRelay(value: "")
    var messages : BehaviorRelay<[MessageItem]> = BehaviorRelay(value: [])
    var goBack : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var sendMessage : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var isBlocked:Bool = false
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var sdk = PixelPhotoSDK.shared
    var user : UserModel?

    init(user:UserModel) {
        
        self.user = user
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.getChatMessages().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.sendMessage
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.sendMEssage().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.blockUnblockUser
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.blockUser().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.deleteMessageItem
            .asDriver()
            .filter({$0 != nil})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.removeMessage(item: value!).asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.clearMessagesTrig
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                return self.clearMessage().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
    }
    
    func removeMessage(item:MessageItem)->Observable<Bool>{
        return self.sdk.chatProvider.rx_deleteSpecificChat(userID: "\(self.user!.user_id!)", messages: ["\(item.id!)"])
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    return self.getChatMessages()
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func sendMEssage()->Observable<Bool>{
        return self.sdk.chatProvider.rx_sendMessages(userID: "\(self.user!.user_id!)", message: self.messageTxt.value, hashID: String.md5(string: self.messageTxt.value))
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<SendMessageResponse> in
                return Observable.just(SendMessageResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    return self.getChatMessages()
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func clearMessage()->Observable<Bool>{
        return self.sdk.chatProvider.rx_clearMessage(userID: "\(self.user!.user_id!)")
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.messages.accept([])
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func blockUser()->Observable<Bool>{
        return self.sdk.profileProvider.rx_blockUnBlockUser(userID: self.user!.user_id!)
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.goBack.accept(true)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
    
    func getChatMessages()->Observable<Bool>{
        return self.sdk.chatProvider.rx_getUserChats(userID: "\(self.user!.user_id!)")
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<GetChatMessageResponse> in
                return Observable.just(GetChatMessageResponse(status: "400", message: error.localizedDescription))
            }).flatMapLatest({ (response) -> Observable<Bool> in
                
                if response.code == "200" {
                    self.isBlocked = (response.data?.is_blocked!)!
                    let temp = (response.data?.messages!)!
                    self.messages.accept(temp.reversed())
                    self.cleanText.accept(true)
                    return Observable.just(true)
                }
                
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            })
    }
}
