//
//  PPAddIViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPAddPostSelectViewController: UIViewController {
    
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
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.circleMenu.onTap()
    }
    
    func setupView(){
        self.circleMenu.delegate = self
        self.circleMenu.isSelected = true
    }
    
    
    func setupRx(){
        
        self.contentView.rx
            .swipeGesture(.down)
            .when(.recognized)
            .subscribe({ _ in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.contentView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe({ _ in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension PPAddPostSelectViewController : CircleMenuDelegate {
    
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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
        
        var type:POSTTYPE?
        
        if atIndex == 0 {
            type = POSTTYPE.GIF
        }else if atIndex == 1 {
            type = POSTTYPE.IMAGE
        }else if atIndex == 2 {
            type = POSTTYPE.YOUTUBE
        }else if atIndex == 3 {
            type = POSTTYPE.VIDEO
        }
        
        self.dismiss(animated: true) {
            self.onClicked!(type!)
        }
    }
}
