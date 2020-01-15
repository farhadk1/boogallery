//
//  DirectoryHelper.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 03/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

extension FileManager{
    
    static func encodeVideo(videoURL: URL)->Observable<String>{
        
        return Observable.create { observer in
            
            let avAsset = AVURLAsset(url: videoURL)
            let startDate = Date()
            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
            
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString
            
            let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            
            let filePath = docDir2.appendingPathComponent("rendered-Video.mp4")
            FileManager.deleteFile(filePath!)
            
            if FileManager.default.fileExists(atPath: myDocPath!){
                do{
                    try FileManager.default.removeItem(atPath: myDocPath!)
                }catch let error{
                      observer.onError(error)
                }
            }
            
            exportSession?.outputURL = filePath
            exportSession?.outputFileType = AVFileType.mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRange(start: start, duration: avAsset.duration)
            exportSession?.timeRange = range
            
            exportSession!.exportAsynchronously{() -> Void in
                switch exportSession!.status{
                case .failed:
                    print("\(exportSession!.error!)")
                    observer.onError(exportSession!.error!)
                case .cancelled:
                    print("Export cancelled")
                case .completed:
                    let endDate = Date()
                    let time = endDate.timeIntervalSince(startDate)
                    print(time)
                    print("Successful")
                    print(exportSession?.outputURL ?? "")
                    observer.onNext((exportSession?.outputURL?.absoluteString)!)
                default:
                    break
                }
            }

            return Disposables.create {
                
            }
        }
    }
    
    static func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else{
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
            print("Remove image success!!")
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    func saveImageStory(image:UIImage)->Observable<String>{
        return Observable.create { observer in
            let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            
            // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
            // *Don't worry it won't be shown in Photos app.
            let imageName = "story.jpg"
            
            
            let imagePath = documentDirectory.appendingPathComponent(imageName)
            
            print("File Exist : \(self.fileExists(atPath: imagePath))")
            print(imagePath)
            
            if self.fileExists(atPath: imagePath) {
                do{
                    try self.removeItem(atPath: imagePath)
                    print("File removed")
                }catch{
                    observer.on(.next("File does't exist"))
                }
            }
            
            // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
            if let data = image.jpegData(compressionQuality: 0.6) {
                // Save cloned image into document directory
                do {
                    try data.write(to: URL(fileURLWithPath: imagePath), options: Data.WritingOptions.atomic)
                    print("Save image successfully.")
                    observer.on(.next(imagePath))
                }catch{
                    observer.on(.next("Save image failed."))
                }
            }
            return Disposables.create {
                
            }
        }
    }
    
    func saveImageObs(image:UIImage)->Observable<String>{
        return Observable.create { observer in
            let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            
            // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
            // *Don't worry it won't be shown in Photos app.
            let imageName = "profileTemp.jpg"
            
            
            let imagePath = documentDirectory.appendingPathComponent(imageName)
            
            print("File Exist : \(self.fileExists(atPath: imagePath))")
            print(imagePath)
            
            if self.fileExists(atPath: imagePath) {
                do{
                    try self.removeItem(atPath: imagePath)
                    print("File removed")
                }catch{
                    observer.on(.next("File does't exist"))
                }
            }
            
            // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
            if let data = image.jpegData(compressionQuality: 0.6) {
                // Save cloned image into document directory
                do {
                    try data.write(to: URL(fileURLWithPath: imagePath), options: Data.WritingOptions.atomic)
                    print("Save image successfully.")
                    observer.on(.next(imagePath))
                }catch{
                    observer.on(.next("Save image failed."))
                }
            }
            return Disposables.create {
                
            }
        }
    }
    
    func savePostImage(image:UIImage)->String {
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        
        // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
        // *Don't worry it won't be shown in Photos app.
        let imageName = String.randomStringWithLength(length: 10) + ".jpg"
        
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        
        print("File Exist : \(self.fileExists(atPath: imagePath))")
        print(imagePath)
        
//        if self.fileExists(atPath: imagePath) {
//            try! self.removeItem(atPath: imagePath)
//            print("File removed")
//        }
        
        // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
        if let data = image.jpegData(compressionQuality: 0.6) {
            // Save cloned image into document directory
            try! data.write(to: URL(fileURLWithPath: imagePath), options: Data.WritingOptions.atomic)
            print("Save image successfully.")
        }
        
        return imagePath
    }
    
    func saveThumbNailImage(image:UIImage)->String{
        
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        
        // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
        // *Don't worry it won't be shown in Photos app.
        let imageName = "thumbNail.jpg"
        
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        
        print("File Exist : \(self.fileExists(atPath: imagePath))")
        print(imagePath)
        
        if self.fileExists(atPath: imagePath) {
            try! self.removeItem(atPath: imagePath)
            print("File removed")
        }
        
        // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
        if let data = image.jpegData(compressionQuality: 0.6) {
            // Save cloned image into document directory
            try! data.write(to: URL(fileURLWithPath: imagePath), options: Data.WritingOptions.atomic)
            print("Save image successfully.")
        }
        
        return imagePath
    }
    
    func saveImage(image:UIImage)->String{
        
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        
        // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
        // *Don't worry it won't be shown in Photos app.
        let imageName = "profileTemp.jpg"
        
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        
        print("File Exist : \(self.fileExists(atPath: imagePath))")
        print(imagePath)
        
        if self.fileExists(atPath: imagePath) {
            try! self.removeItem(atPath: imagePath)
            print("File removed")
        }
        
        // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
        if let data = image.jpegData(compressionQuality: 0.6) {
            // Save cloned image into document directory
            try! data.write(to: URL(fileURLWithPath: imagePath), options: Data.WritingOptions.atomic)
            print("Save image successfully.")
        }
        
        return imagePath
    }
    
    func saveImage(image:UIImage){
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        
        // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
        // *Don't worry it won't be shown in Photos app.
        let imageName = "profileTemp.jpg"
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        
        print("File Exist : \(self.fileExists(atPath: imagePath))")
        print(imagePath)
        
        if self.fileExists(atPath: imagePath) {
            do{
                try! self.removeItem(atPath: imagePath)
                print("File removed")
            }catch{
                print("File does't exist")
            }
        }
        
        // Encode this image into JPEG. *You can add conditional based on filetype, to encode into JPEG or PNG
        if let data = image.jpegData(compressionQuality: 0.6) {
            // Save cloned image into document directory
            do {
                try! data.write(to: URL(fileURLWithPath: imagePath), options: Data.WritingOptions.atomic)
                print("Save image successfully.")
            }catch{
                print("Save image failed.")
            }
        }
    }
}

