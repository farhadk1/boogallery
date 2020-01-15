//
//  ColorExt.swift
//  Pixel Photo
//
//  Created by Olivin Esguerra on 03/01/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit

struct COLOR {
    static let DARKPINK = UIColor(red: 138.0/255.0, green: 29.0/255.0, blue: 57.0/255.0, alpha: 1.0)
}
extension UIColor {
    
    @nonobjc class var riGradientRedColor: UIColor {
        return UIColor(red: 138.0 / 255.0, green: 29.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var riGradientPinkColor: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 181.0 / 255.0, alpha: 1.0)
    }
}
