//
//  Protocol.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 15/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import PixelPhotoSDK
protocol didSelectType {
    func didselecttype(type:String)
}
protocol didSelectEmbbedVideoDelegate {
    func didSelectEmbbedVideo(videoURL:String)
}
protocol didSelectGIFDelegate {
    func didSelectGIF(GIFUrl:String)
}
