//
//  PPIntroViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 25/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

class PPIntroViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var signUpLbl: UILabel!
    @IBOutlet weak var welcomeLbl: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginView: GradientView!
    @IBOutlet weak var registerView: GradientView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    let titleArr = [NSLocalizedString("Title1", comment: ""),
                    NSLocalizedString("Title2", comment: ""),
                    NSLocalizedString("Title3", comment: "")]
    
    let descArr = [NSLocalizedString("Desc1", comment: ""),
                   NSLocalizedString("Desc2", comment: ""),
                   NSLocalizedString("Desc3", comment: "")]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
//        setupRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func setupView(){
        self.welcomeLbl.text = NSLocalizedString("Welcome to PixelPhoto", comment: "")
        self.loginLbl.text = NSLocalizedString("Sign In", comment: "")
        self.signUpLbl.text = NSLocalizedString("Register", comment: "")
        
        self.loginView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
        self.registerView.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 0.0, y: 1.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
        
        self.contentCollectionView.delegate = self
        self.contentCollectionView.dataSource = self
        
        self.loginView.isRoundedRect(cornerRadius: 20)
        self.registerView.isRoundedRect(cornerRadius: 20)
        
        self.contentCollectionView.register(UINib(nibName: "PPIntroItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPIntroItemCollectionViewCellID")
    }
    
//    func setupRx(){
//
//        self.loginView.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe({ _ in
////                self.setupLoginFlow()
//            }).disposed(by: self.disposeBag)
//
//        self.registerView.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe({ _ in
////                self.setupRegFlow()
//            }).disposed(by: self.disposeBag)
//    }
    
//    func setupLoginFlow(){
//        
//        SwinjectStoryboard.defaultContainer.assembleLogin()
//        let sb = SwinjectStoryboard.create(name: "Main",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let nextVC = sb.instantiateViewController(withIdentifier: "PPLoginViewControllerID") as! PPLoginViewController
//        nextVC.navigationItem.hidesBackButton = true
//        self.navigationController?.pushViewController(nextVC, animated: true)
//        
//        nextVC.onRegClicked = {
//            nextVC.navigationController?.popViewController(animated: true)
//            self.setupRegFlow()
//        }
//    }
//    
//    func setupRegFlow(){
//        
//        SwinjectStoryboard.defaultContainer.assembleRegister()
//        let sb = SwinjectStoryboard.create(name: "Main",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let nextVC = sb.instantiateViewController(withIdentifier: "PPRegisterViewControllerID") as! PPRegisterViewController
//        nextVC.navigationItem.hidesBackButton = true
//        self.navigationController?.pushViewController(nextVC, animated: true)
//        
//        nextVC.onLoginClicked = {
//            nextVC.navigationController?.popViewController(animated: true)
//            self.setupLoginFlow()
//        }
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension PPIntroViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroItem", for: indexPath) as! IntroItem
        cell.titleLbl.text = self.titleArr[indexPath.row]
        cell.descLbl.text = self.descArr[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
