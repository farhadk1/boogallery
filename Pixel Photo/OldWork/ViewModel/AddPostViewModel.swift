//
//  AddPostViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 09/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import PixelPhotoFramework

protocol AddPostViewModeling : BaseViewModelling {
    var type:BehaviorRelay<POSTTYPE> { get set }
    var gifList:BehaviorRelay<[GiphyItem]> { get set }
    var imageURLs:BehaviorRelay<[String]> { get set }
    var images:BehaviorRelay<[UIImage]> { get set }
    var videoUrl:BehaviorRelay<String> { get set }
    var mentionedContact:BehaviorRelay<[UserModel]> { get set }
    var gifUrl:BehaviorRelay<String> { get set }
    var captionText:BehaviorRelay<String> { get set }
    var postLinkURL:BehaviorRelay<String> { get set }
    var submitData :BehaviorRelay<Bool> { get set }
    var dismissPage :BehaviorRelay<Bool> { get set }
    var thumbNailUrl : BehaviorRelay<String>{ get set }
    var mentionedText: BehaviorRelay<NSMutableAttributedString>{ get set }
    var vc : UIViewController? { get set }
    
    func deleteItem(row:Int)
}

class AddPostViewModel: AddPostViewModeling {
    
    var onErrorTrigger: BehaviorRelay<(String, String)> = BehaviorRelay(value: ("",""))
    
    fileprivate var indicator = ActivityIndicator()
    fileprivate var progress = ProgressDialog()
    fileprivate var disposeBag = DisposeBag()
    
    var type: BehaviorRelay<POSTTYPE> = BehaviorRelay(value: .NONE)
    var gifList: BehaviorRelay<[GiphyItem]> = BehaviorRelay(value: []) //GIF
    var mentionedText: BehaviorRelay<NSMutableAttributedString> = BehaviorRelay(value: NSMutableAttributedString(string: "")) // CAPTION
    var captionText: BehaviorRelay<String> = BehaviorRelay(value: "") // CAPTION
    var postLinkURL: BehaviorRelay<String> = BehaviorRelay(value: "") // youtube,video url links
    var imageURLs: BehaviorRelay<[String]> = BehaviorRelay(value: []) // local image
    var images:BehaviorRelay<[UIImage]> = BehaviorRelay(value: []) // actual image
    var videoUrl : BehaviorRelay<String> = BehaviorRelay(value: "") //local video url
    var thumbNailUrl : BehaviorRelay<String> = BehaviorRelay(value: "") //thumbnail url
    var mentionedContact :  BehaviorRelay<[UserModel]> = BehaviorRelay(value: []) // menthiod contacts
    var gifUrl : BehaviorRelay<String> = BehaviorRelay(value: "")
    var submitData: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var dismissPage: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var encodedVideo = ""
    
    var vc : UIViewController?
    
    var sdk = PixelPhotoSDK.shared
    
    let fileManager = FileManager()

    init(type : POSTTYPE) {
        self.type.accept(type)
        
        self.indicator.asObservable()
            .bind(to: progress.progressDialogAnimation)
            .disposed(by: self.disposeBag)
        
        self.type.asDriver()
            .drive(onNext : { value in
                
                if value == POSTTYPE.GIF {
                    self.images.accept([])
                    self.imageURLs.accept([])
                    self.videoUrl.accept("")
                    self.thumbNailUrl.accept("")
                     self.postLinkURL.accept("")
                }else if value == POSTTYPE.IMAGE || value == POSTTYPE.IMAGES {
                    self.videoUrl.accept("")
                    self.thumbNailUrl.accept("")
                    self.postLinkURL.accept("")
                    self.gifUrl.accept("")
                }else if value == POSTTYPE.VIDEO {
                    self.images.accept([])
                    self.imageURLs.accept([])
                     self.postLinkURL.accept("")
                    self.gifUrl.accept("")
                }else if value == POSTTYPE.YOUTUBE {
                    self.gifUrl.accept("")
                    self.images.accept([])
                    self.imageURLs.accept([])
                    self.videoUrl.accept("")
                    self.thumbNailUrl.accept("")
                }
                
            }).disposed(by: self.disposeBag)
        
        self.mentionedContact.asDriver()
            .drive(onNext: { value in
                
                let temp = self.mentionedText.value
                
                let withAttribute = [
                    NSAttributedString.Key.foregroundColor : UIColor.lightGray
                    ] as [NSAttributedString.Key : Any]
                
                if temp.string == "" && value.count > 0 {
                    temp.append(NSAttributedString(string: "With ", attributes: withAttribute))
                }
                
                let userAttribute = [
                    NSAttributedString.Key.foregroundColor : UIColor.red
                ] as [NSAttributedString.Key : Any]
                
                for user in value {
                    if user.fname != "" {
                       temp.append(NSAttributedString(string: "@\(user.username!) ", attributes: userAttribute))
                    }
                }
                
                self.mentionedText.accept(temp)
            }).disposed(by: self.disposeBag)
        
        
        self.submitData
            .asDriver()
            .filter({$0})
            .flatMapLatest({ (value) -> Driver<Bool> in
                if self.type.value == POSTTYPE.GIF {
                    return self.postGIF().asDriver(onErrorJustReturn: false)
                }else if self.type.value == POSTTYPE.IMAGE || self.type.value == POSTTYPE.IMAGES {
                    return self.postImages().asDriver(onErrorJustReturn: false)
                }else if self.type.value == POSTTYPE.VIDEO {
                    return self.postVideo().asDriver(onErrorJustReturn: false)
                }
                return self.postLink().asDriver(onErrorJustReturn: false)
            })
            .drive(onNext : { value in
                
            }).disposed(by: self.disposeBag)
        
        self.videoUrl
            .asDriver(onErrorJustReturn: "")
            .filter({$0 != ""})
            .drive(onNext : { value in
                let ass = AVAsset(url:URL(string: value)!)
                if let videoThumbnail = ass.videoThumbnail{
                    print("Video Thumbnail Success")
                    self.thumbNailUrl.accept(FileManager().saveThumbNailImage(image: videoThumbnail))
                }
                print(value)
                self.encodedVideo = value
            }).disposed(by: self.disposeBag)
    }
    
    func deleteItem(row:Int){
        
        if self.type.value == POSTTYPE.GIF {
            self.gifUrl.accept("")
        }else if self.type.value == POSTTYPE.VIDEO {
            self.videoUrl.accept("")
        }else if self.type.value == POSTTYPE.YOUTUBE {
            self.postLinkURL.accept("")
        }else if self.type.value == POSTTYPE.IMAGE {
            var tempURLArray = self.imageURLs.value
            var tempImgArray = self.images.value
            tempURLArray.remove(at: 0)
            tempImgArray.remove(at: 0)
            self.imageURLs.accept(tempURLArray)
            self.images.accept(tempImgArray)
        }else if self.type.value == POSTTYPE.IMAGES {
            var tempURLArray = self.imageURLs.value
            var tempImgArray = self.images.value
            tempURLArray.remove(at: row)
            tempImgArray.remove(at: row)
            self.imageURLs.accept(tempURLArray)
            self.images.accept(tempImgArray)
        }
    }
    
    
    private func generateCaption() -> String{
        var temp = self.captionText.value
        
        if temp == NSLocalizedString("Add post caption. #hashtag..@mention?", comment: "") {
            temp = ""
        }
        let tempMentionedContacts = self.mentionedContact.value
        
        if tempMentionedContacts.count > 0 {
            temp.append("\nWith ")
            for user in tempMentionedContacts {
                 temp.append("@\(user.username!) ")
            }
        }
        print(temp)
        return temp
    }
    
    
    func postImages()->Observable<Bool>{
        
        if self.imageURLs.value.count == 0 {
            return Observable.just(false)
        }
        
        for urls in self.imageURLs.value {
            print(urls)
        }
        
        return (self.sdk.postProvider.rx_postNewImage(caption: self.generateCaption(), imgUrls: self.imageURLs.value)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                
                for imgUrl in self.imageURLs.value {
                    FileManager.deleteFile(URL(string: imgUrl)!)
                }
                
                if response.code == "200" {
                    self.imageURLs.accept([])
                    self.dismissPage.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
            
    }
    
    func postVideo()->Observable<Bool>{
        
        if self.encodedVideo == "" {
            return Observable.just(false)
        }
        
        return (self.sdk.postProvider.rx_postVideo(caption: self.generateCaption(), thumbNail: self.thumbNailUrl.value, videoURL: self.encodedVideo)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    FileManager.deleteFile(URL(string: self.thumbNailUrl.value)!)
                    FileManager.deleteFile(URL(string: self.encodedVideo)!)
                    self.dismissPage.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func postGIF()->Observable<Bool>{
        
        if self.gifUrl.value == "" {
            return Observable.just(false)
        }
        
        return (self.sdk.postProvider.rx_postGIFs(caption: self.generateCaption(), gifUrl: self.gifUrl.value)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.dismissPage.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
    func postLink()->Observable<Bool>{
        
        if self.postLinkURL.value == "" {
             return Observable.just(false)
        }
        
        return (self.sdk.postProvider.rx_postVideoFromUrl(caption: self.generateCaption(), videoURL: self.postLinkURL.value)
            .trackActivity(self.indicator)
            .catchError({ (error) -> Observable<GeneralResponse> in
                return Observable.just(GeneralResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ (response) -> Observable<Bool> in
                if response.code == "200" {
                    self.dismissPage.accept(true)
                    return Observable.just(true)
                }
                self.onErrorTrigger.accept(((response.status)!,(response.errors?.error_text)!))
                return Observable.just(false)
            }))
    }
    
}
