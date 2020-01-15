//
//  SelectGIFViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 11/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol SelectGIFViewModeling : BaseViewModelling , HasLoadmoreAndPulltoRefresh,NeedsToInitialize {
    var gifList: BehaviorRelay<[GiphyItem]> { get set }
    var searchGifList: BehaviorRelay<[GiphyItem]> { get set }
    var selected: BehaviorRelay<[GiphyItem]> { get set }
    var isSearching: BehaviorRelay<Bool> { get set }
    var queryString: BehaviorRelay<String> { get set }
}

class SelectGIFViewModel: SelectGIFViewModeling {
   
    var queryString: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()
    
    var sdk = PixelPhotoSDK.shared
    
    var isInitialize: BehaviorRelay<Bool>  = BehaviorRelay(value: false)
    var searchGifList: BehaviorRelay<[GiphyItem]> = BehaviorRelay(value: [])
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    var offset: Int = 0
    var state: BehaviorRelay<DATASTATUS> = BehaviorRelay(value: DATASTATUS.NONE)
    var finishedInfiniteScroll: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var finishedPullToRefresh: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isSearching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var selected: BehaviorRelay<[GiphyItem]>
    var gifList: BehaviorRelay<[GiphyItem]> = BehaviorRelay(value: [])
    
    init(selected: BehaviorRelay<[GiphyItem]>) {
        self.selected = selected
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.state.asDriver()
            .filter({$0 != DATASTATUS.NONE})
            .flatMapLatest { (value) -> Driver<Bool> in
                
                if value == DATASTATUS.INITIAL {
                    return self.searchGif(query: self.queryString.value, state: DATASTATUS.INITIAL).asDriver(onErrorJustReturn: false)
                }
                
                 return self.searchGif(query: self.queryString.value, state: DATASTATUS.LOADMORE).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.isInitialize
            .asDriver()
            .flatMapLatest { (value) -> Driver<Bool> in
                return self.getTrending(state: DATASTATUS.INITIAL, hasTracker: true).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.queryString
            .asDriver()
            .flatMapLatest { (value) -> Driver<Bool> in
                if value == "" {
                    self.isSearching.accept(false)
                    return Driver.just(false)
                }
                 self.isSearching.accept(true)
                return self.searchGif(query: value, state: DATASTATUS.INITIAL).asDriver(onErrorJustReturn: false)
            }
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
    }
    
    func getRandomGIFs(state:DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.offset + 1
        }
        
        if hasTracker {
            return (self.sdk.gifphyProvider.rx_getRandomGifs()
                .trackActivity(self.indicator)
                .catchError({ (error) -> Observable<GiphyResponse> in
                    return Observable.just(GiphyResponse(status: "400", message: error.localizedDescription))
                })
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    if response.status == nil {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.gifList.accept(response.data!)
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                var temp = self.gifList.value
                                temp.append(contentsOf: response.data!)
                                self.gifList.accept(temp)
                            }else{
                                self.offset = self.offset - 1
                            }
                            self.finishedInfiniteScroll.accept(true)
                        }
                        return Observable.just(true)
                    }else{
                        self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                        return Observable.just(false)
                    }
                }))
        }
        
        return (self.sdk.gifphyProvider.rx_getRandomGifs()
            .catchError({ (error) -> Observable<GiphyResponse> in
                return Observable.just(GiphyResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.status == nil {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.gifList.accept(response.data!)
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.gifList.value
                            temp.append(contentsOf: response.data!)
                            self.gifList.accept(temp)
                        }else{
                            self.offset = self.offset - 1
                        }
                        self.finishedInfiniteScroll.accept(true)
                    }
                    return Observable.just(true)
                }else{
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }
            }))
    }
    
    func searchGif(query:String,state:DATASTATUS)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.offset + 1
        }
        
        return (self.sdk.gifphyProvider.rx_getSearch(query: query, offset: self.offset)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GiphyResponse> in
                return Observable.just(GiphyResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.status == nil {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.searchGifList.accept(response.data!)
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.gifList.value
                            temp.append(contentsOf: response.data!)
                            self.searchGifList.accept(temp)
                        }else{
                            self.offset = self.offset - 1
                        }
                        self.finishedInfiniteScroll.accept(true)
                    }
                    return Observable.just(true)
                }else{
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }
            }))
    }
    
    func getTrending(state:DATASTATUS,hasTracker:Bool)->Observable<Bool>{
        
        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
            self.offset = 0
        }else if state == DATASTATUS.LOADMORE {
            self.offset = self.offset + 1
        }
        
        if hasTracker {
            return (self.sdk.gifphyProvider.rx_getTrending()
                .trackActivity(self.indicator)
                .catchError({ (error) -> Observable<GiphyResponse> in
                    return Observable.just(GiphyResponse(status: "400", message: error.localizedDescription))
                })
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ (response) -> Observable<Bool> in
                    if response.status == nil {
                        if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                            self.gifList.accept(response.data!)
                            self.finishedPullToRefresh.accept(true)
                        }else if state == DATASTATUS.LOADMORE {
                            if response.data!.count > 0 {
                                var temp = self.gifList.value
                                temp.append(contentsOf: response.data!)
                                self.gifList.accept(temp)
                            }else{
                                self.offset = self.offset - 1
                            }
                            self.finishedInfiniteScroll.accept(true)
                        }
                        return Observable.just(true)
                    }else{
                        self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                        return Observable.just(false)
                    }
                }))
        }
        
        return (self.sdk.gifphyProvider.rx_getTrending()
            .catchError({ (error) -> Observable<GiphyResponse> in
                return Observable.just(GiphyResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.status == nil {
                    if state == DATASTATUS.INITIAL || state == DATASTATUS.PULLTOREFRESH {
                        self.gifList.accept(response.data!)
                        self.finishedPullToRefresh.accept(true)
                    }else if state == DATASTATUS.LOADMORE {
                        if response.data!.count > 0 {
                            var temp = self.gifList.value
                            temp.append(contentsOf: response.data!)
                            self.gifList.accept(temp)
                        }else{
                            self.offset = self.offset - 1
                        }
                        self.finishedInfiniteScroll.accept(true)
                    }
                    return Observable.just(true)
                }else{
                    self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                    return Observable.just(false)
                }
            }))
    }
}
