//
//  ProgressDialog.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit

class ProgressDialog {
    
    init() {
        SKActivityIndicator.spinnerStyle(.spinningCircle)
    }
    
    func show(){
        SKActivityIndicator.show()
    }
    
    func dismiss(){
        SKActivityIndicator.dismiss()
    }
}
