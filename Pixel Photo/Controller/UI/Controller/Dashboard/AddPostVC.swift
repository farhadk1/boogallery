//
//  AddPostVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 04/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoSDK

class AddPostVC: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var circleMenu: CircleMenu!
    var onClicked: ((POSTTYPE) -> Void)?
    
    var menuOpened = false
    
    let items: [(icon: String, color: UIColor)] = [
        ("ic_tooltip_gif", UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)),
        ("ic_tooltip_image", UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)),
        ("ic_tooltip_link", UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)),
        ("ic_tooltip_video", UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.circleMenu.onTap()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI(){
        self.circleMenu.delegate = self
        self.circleMenu.isSelected = true
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissTapped(_:)))
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(dismissTap)
    }
    @objc func dismissTapped(_ sender: UITapGestureRecognizer) {
//        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddPostVC : CircleMenuDelegate {
    
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        
        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
    }
    
    func menuOpened(_ circleMenu: CircleMenu) {
        self.menuOpened = true
    }
    
    func menuCollapsed(_ circleMenu: CircleMenu) {
        self.menuOpened = false
        
    }
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
        let vc = R.storyboard.post.addPostPostVC()
        if atIndex == 0 {
            vc!.type = "GIF"
        }else if atIndex == 1 {
            vc!.type = "IMAGE"
        }else if atIndex == 2 {
            vc!.type = "YOUTUBE"

        }else if atIndex == 3 {
            vc!.type = "VIDEO"
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
