//
//  PPStoryTextColorViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 02/02/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class PPStoryTextColorViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var firstSetCollectionView: UICollectionView!
    @IBOutlet weak var secondSetCollectionView: UICollectionView!
    @IBOutlet weak var thirdSetCollectionView: UICollectionView!
    @IBOutlet weak var fourthSetCollectionView: UICollectionView!
    var onClicked: ((UIColor) -> Void)?
    var disposeBag = DisposeBag()
    
    var color = [
        UIColor.hexStringToUIColor(hex: "#1abc9c"),
        UIColor.hexStringToUIColor(hex: "#2ecc71"),
        UIColor.hexStringToUIColor(hex: "#3498db"),
        UIColor.hexStringToUIColor(hex: "#9b59b6"),
        UIColor.hexStringToUIColor(hex: "#34495e"),
        UIColor.hexStringToUIColor(hex: "#f1c40f"),
        UIColor.hexStringToUIColor(hex: "#e67e22"),
        UIColor.hexStringToUIColor(hex: "#e74c3c"),
        UIColor.hexStringToUIColor(hex: "#ecf0f1"),
        UIColor.hexStringToUIColor(hex: "#95a5a6"),
        UIColor.hexStringToUIColor(hex: "#D81B60"),
        UIColor.hexStringToUIColor(hex: "#3D5AFE"),
        UIColor.hexStringToUIColor(hex: "#795548"),
        UIColor.hexStringToUIColor(hex: "#000000"),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupRx()
    }
    
    func setupView(){
        
        self.firstSetCollectionView.delegate = self
        self.firstSetCollectionView.dataSource = self
        
        self.secondSetCollectionView.delegate = self
        self.secondSetCollectionView.dataSource = self
        
        self.thirdSetCollectionView.delegate = self
        self.thirdSetCollectionView.dataSource = self
        
        self.fourthSetCollectionView.delegate = self
        self.fourthSetCollectionView.dataSource = self
        
        self.firstSetCollectionView.register(UINib(nibName: "PPColorItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPColorItemCollectionViewCellID")
        self.secondSetCollectionView.register(UINib(nibName: "PPColorItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPColorItemCollectionViewCellID")
        self.thirdSetCollectionView.register(UINib(nibName: "PPColorItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPColorItemCollectionViewCellID")
        self.fourthSetCollectionView.register(UINib(nibName: "PPColorItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PPColorItemCollectionViewCellID")
    }
    
    func setupRx(){
        
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

extension PPStoryTextColorViewController : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.firstSetCollectionView {
            return 4
        }else if collectionView == self.secondSetCollectionView {
            return 4
        }else if collectionView == self.thirdSetCollectionView {
            return 4
        }
        
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.firstSetCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPColorItemCollectionViewCellID", for: indexPath) as! PPColorItemCollectionViewCell
            cell.backgroundColor = UIColor.clear
            cell.bgView.backgroundColor = self.color[indexPath.row]
            return cell
        }else if collectionView == self.secondSetCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPColorItemCollectionViewCellID", for: indexPath) as! PPColorItemCollectionViewCell
            cell.backgroundColor = UIColor.clear
            cell.bgView.backgroundColor = self.color[indexPath.row + 4]
            return cell
        }else if collectionView == self.thirdSetCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPColorItemCollectionViewCellID", for: indexPath) as! PPColorItemCollectionViewCell
            cell.backgroundColor = UIColor.clear
            cell.bgView.backgroundColor = self.color[indexPath.row + 8]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPColorItemCollectionViewCellID", for: indexPath) as! PPColorItemCollectionViewCell
        
        if indexPath.row == 2 {
            cell.bgView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
        }else if indexPath.row == 3 {
            cell.bgView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
        }else{
            cell.backgroundColor = UIColor.clear
            cell.bgView.backgroundColor = self.color[indexPath.row + 12]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var color : UIColor?
        
        if collectionView == self.firstSetCollectionView {
            color = self.color[indexPath.row]
        }else if collectionView == self.secondSetCollectionView {
            color = self.color[indexPath.row + 4]
        }else if collectionView == self.thirdSetCollectionView {
            color = self.color[indexPath.row + 8]
        }else{
            
            if indexPath.row != 2 && indexPath.row == 3 {
                color  = self.color[indexPath.row + 12]
            }
        }
        self.dismiss(animated: true) {
            if color != nil {
                self.onClicked!(color!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width / 4 , height: collectionView.frame.size.height)
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
