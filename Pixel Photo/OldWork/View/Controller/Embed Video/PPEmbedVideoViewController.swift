//
//  PPEmbedVideoViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 10/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PPEmbedVideoViewController: UIViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var urlTxtView: UITextView!
    
    @IBOutlet weak var embedLbl: UILabel!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupView()
        setupRx()
    }
    
    func setupRx(){
        self.submitBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by:self.disposeBag)
        
        self.cancelBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by:self.disposeBag)
    }
    
    func setupView(){
        
        self.embedLbl.text = NSLocalizedString("Embed Video", comment: "")
        self.cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControl.State.normal)
        self.submitBtn.setTitle(NSLocalizedString("Submit", comment: ""), for: UIControl.State.normal)
    }
}
