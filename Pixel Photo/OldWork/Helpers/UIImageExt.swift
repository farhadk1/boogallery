//
//  UIImageExt.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 05/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage( aspectRation: CGFloat) -> UIImage {
        
        let newWidth  = self.size.width * aspectRation
        let newHeight = self.size.height * aspectRation
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}
