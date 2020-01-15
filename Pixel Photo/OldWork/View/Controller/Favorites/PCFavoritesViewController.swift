//
//  PCFavoritesViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 21/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PCFavoritesViewController: UIViewController {
    
    @IBOutlet weak var contentTblView: UITableView!
    
    var viewModel : FavoritePostViewModeling?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.contentTblView.register(UINib(nibName: "PPYoutubeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPYoutubeItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPMultiImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPMultiImageItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPLinkItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPLinkItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPVideoItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPVideoItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPGIFItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPGIFItemTableViewCellID")
        self.contentTblView.register(UINib(nibName: "PPImageItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PPImageItemTableViewCellID")
    }
    
    func setupRx(){
        
    }
}
