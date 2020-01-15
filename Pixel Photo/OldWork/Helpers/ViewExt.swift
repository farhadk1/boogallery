//
//  ViewExt.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
extension UIView {
    
    static func makeScreenshot(view:UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { (context) in
            view.layer.render(in: context.cgContext)
        }
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func isRoundedRect(cornerRadius : CGFloat,hasBorderColor : UIColor?){
         self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        if hasBorderColor != nil {
            self.layer.borderWidth = 1
            self.layer.borderColor = hasBorderColor!.cgColor
        }
    }
    
    func addShadow(){
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
    }
    
    func applyGradient(colours: [UIColor], start: CGPoint?, end: CGPoint?,borderColor:UIColor) -> Void {
        
        var gradient: CAGradientLayer!
        
        gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = start!
        gradient.endPoint = end!
        gradient.cornerRadius = 10
        gradient.borderColor = borderColor.cgColor
        gradient.borderWidth = 1
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
        {
            topLayer.removeFromSuperlayer()
        }
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(colours: [UIColor], start: CGPoint?, end: CGPoint?) -> Void {
        
        var gradient: CAGradientLayer!
        
        gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = start!
        gradient.endPoint = end!
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
        {
            topLayer.removeFromSuperlayer()
        }
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func roundedRect(cornerRadius : CGFloat,borderColor : UIColor){
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
    
    func isRoundedRect(cornerRadius : CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .topRight, .bottomLeft, .bottomRight],
                                     cornerRadii: CGSize(width:cornerRadius, height: cornerRadius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func isCircular(){
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true
        self.layer.masksToBounds = true
    }
    
    func isCircular(borderColor : UIColor){
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}
