//
//  AddToPostVC.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 15/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoSDK

class AddToPostVC: UIViewController {
    
    @IBOutlet weak var closeBtnTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var closeBtn: UIButton!
    var disposeBag = DisposeBag()
    var delegate:didSelectType?
    
    let list = [
        (NSLocalizedString("Image Gallery", comment: ""),UIImage(named: "ic_tooltip_image")),
        (NSLocalizedString("Video Gallery", comment: ""),UIImage(named: "ic_tooltip_video")),
        (NSLocalizedString("Camera", comment: ""),UIImage(named: "ic_capture_camera")),
        (NSLocalizedString("GIF", comment: ""),UIImage(named: "ic_tooltip_gif")),
        (NSLocalizedString("Embed Video", comment: ""),UIImage(named: "ic_tooltip_link")),
    ]
    
    var onClicked: ((POSTSOURCE) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
    }
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func setupUI(){
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        self.closeBtnTopConstraints.constant = 50
        self.contentTblView.register(UINib(nibName: "PPSelectPostItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPSelectPostItemTableViewCellID")
    }
}

extension AddToPostVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
                self.delegate?.didselecttype(type: "IMAGE")
                break
            case 1:
                self.delegate?.didselecttype(type: "VIDEO")
                break
            case 2:
                self.delegate?.didselecttype(type: "IMAGE")

                break
            case 3:
                self.delegate?.didselecttype(type: "GIF")
                break
            default:
                self.delegate?.didselecttype(type: "YOUTUBE")
                break
            }
        }
    }
    
    
}
