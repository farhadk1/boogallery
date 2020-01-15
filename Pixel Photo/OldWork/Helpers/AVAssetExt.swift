//
//  AVAssetExt.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 13/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import MediaPlayer
import SystemConfiguration
import RxSwift
import RxCocoa

extension AVAsset{
    
    var videoThumbnail:UIImage?{
        let assetImageGenerator = AVAssetImageGenerator(asset: self)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = self.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbNail = UIImage.init(cgImage: imageRef)
            return thumbNail
        } catch {
            return nil
        }
        
    }
}
