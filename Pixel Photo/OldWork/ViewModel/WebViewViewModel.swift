//
//  WebViewViewModel.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoFramework

class WebViewViewModel: WebViewViewModeling {
    
    var url : String!
    
    init(url : String) {
        self.url = url
    }
}
