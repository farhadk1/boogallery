//
//  SettingListViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 23/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol SettingListViewModeling : BaseViewModelling, NeedsToInitialize{
    var userItem : BehaviorRelay<UserModel?> { get set }
}

class SettingListViewModel: SettingListViewModeling {
    
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var userItem: BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
//    var sdk = PixelPhotoSDK.shared
    

    init(user:UserModel) {
        
        self.userItem.accept(user)
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)

    }
    
//    func getUserData()->Observable<Bool>{
//        return (self.sdk.profileProvider.rx_getUserData(userID: "\(PixelPhotoSDK.shared.getMyUserID)")
//            .trackActivity(self.indicator)
//            .catchError({ (error) -> Observable<GetUserDataResponse> in
//                return Observable.just(GetUserDataResponse(status: "400", message: error.localizedDescription))
//            })
//            .observeOn(MainScheduler.instance)
//            .flatMapLatest({ (response) -> Observable<Bool> in
//                if response.code == "200" {
//                    self.userItem.accept(response.data!)
//                    return Observable.just(true)
//                }
//                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
//                return Observable.just(false)
//            }))
//    }
    
}
