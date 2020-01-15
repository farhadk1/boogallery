//
//  AddToPostViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 10/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AddToPostViewController: UIViewController {
    
    @IBOutlet weak var closeBtnTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var disposeBag = DisposeBag()
    
    let list = [
        (NSLocalizedString("Image Gallery", comment: ""),UIImage(named: "ic_tooltip_image")),
        (NSLocalizedString("Video Gallery", comment: ""),UIImage(named: "ic_tooltip_video")),
        (NSLocalizedString("Mention Contact", comment: ""),UIImage(named: "ic_contact_blue")),
        (NSLocalizedString("Camera", comment: ""),UIImage(named: "ic_capture_camera")),
        (NSLocalizedString("GIF", comment: ""),UIImage(named: "ic_tooltip_gif")),
        (NSLocalizedString("Embed Video", comment: ""),UIImage(named: "ic_tooltip_link")),
        ]
    
    var onClicked: ((POSTSOURCE) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        
        self.closeBtnTopConstraints.constant = 50
        
        self.contentTblView.register(UINib(nibName: "PPSelectPostItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPSelectPostItemTableViewCellID")
    }
    
    func setupRx(){
        
        self.closeBtn.setTitleColor(UIColor.mainColor, for: UIControl.State.normal)
        self.closeBtn.setTitle(NSLocalizedString("Close", comment: ""), for: UIControl.State.normal)
        
        
        self.closeBtn.rx.tap
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by:self.disposeBag)
    }
    
    
    
}

extension AddToPostViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PPSelectPostItemTableViewCellID") as! PPSelectPostItemTableViewCell
        cell.titleLbl.text = self.list[indexPath.row].0
        cell.iconImgView.image = self.list[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        self.dismiss(animated: true) {
            switch indexPath.row {
            case 0:
                self.onClicked!(POSTSOURCE.IMAGES)
                break
            case 1:
                self.onClicked!(POSTSOURCE.VIDEOGALLERY)
                break
            case 2:
                self.onClicked!(POSTSOURCE.MENTIONEDCONTACTS)
                break
            case 3:
                self.onClicked!(POSTSOURCE.CAMERA)
                break
            case 4:
                self.onClicked!(POSTSOURCE.GIF)
                break
            default:
                self.onClicked!(POSTSOURCE.YOUTUBE)
                break
            }
        }
    }
    
    
}
