//
//  FavoritePostViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 21/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

protocol FavoritePostViewModeling :
    HasLoadmoreAndPulltoRefresh ,
    BaseViewModelling,
    NeedsToInitialize {
    
    var postItems : BehaviorRelay<[PostItem]> { get set }
}

class FavoritePostViewModel: FavoritePostViewModeling {
    
    var userItem: BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var offset: Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var isInitialize: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var user : BehaviorRelay<UserModel?> = BehaviorRelay(value: nil)
    var postItems : BehaviorRelay<[PostItem]> = BehaviorRelay(value: [])

    fileprivate var disposeBag = DisposeBag()
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    
    var userID:Int?
    
    init(userID:Int) {
        
        self.userID = userID
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .filter({$0})
//            .flatMapLatest({ (value) -> Driver<Bool> in
//                return self.getUserPost().asDriver(onErrorJustReturn: false)
//            })
//            .flatMapLatest({ (value) -> Driver<Bool> in
//                return self.getUserData().asDriver(onErrorJustReturn: false)
//            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
//            .flatMapLatest({ (value) -> Driver<Bool> in
//                return self.getUserPost().asDriver(onErrorJustReturn: false)
//            })
//            .flatMapLatest({ (value) -> Driver<Bool> in
//                return self.getUserData().asDriver(onErrorJustReturn: false)
//            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
    }
    
}
