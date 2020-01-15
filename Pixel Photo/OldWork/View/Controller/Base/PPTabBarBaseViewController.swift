//
//  PPTabBarBaseViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

class PPTabBarBaseViewController: UITabBarController {
    
    var numberOfTapped = 0
    var selectedIndx = 0
    
    var disposeBag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.delegate = self
//
//         self.tabBar.tintColor = UIColor.mainColor
//
//        SwinjectStoryboard.defaultContainer.assembleHomePage()
//        let sb = SwinjectStoryboard.create(name: "Dashboard",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let homeVC = sb.instantiateViewController(withIdentifier: "PPHomeViewControllerID") as! PPHomeViewController
//        let icon1 = UITabBarItem(title: "", image: UIImage(named: "ic_tab_home"), selectedImage: UIImage(named: "ic_tab_home"))
//        homeVC.tabBarItem = icon1
//        icon1.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        let nav1 = UINavigationController(rootViewController: homeVC)
//
//        SwinjectStoryboard.defaultContainer.assembleExplorePage()
//        let exploreVC = sb.instantiateViewController(withIdentifier: "PPExploreViewControllerID") as! PPExploreViewController
//        let icon2 = UITabBarItem(title: "", image: UIImage(named: "ic_tab_explore"), selectedImage: UIImage(named: "ic_tab_explore"))
//        exploreVC.tabBarItem = icon2
//         icon2.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        let nav2 = UINavigationController(rootViewController: exploreVC)
//
//        let addVC = sb.instantiateViewController(withIdentifier: "PPAddPostSelectViewControllerID") as! PPAddPostSelectViewController
//        let icon3 = UITabBarItem(title: "", image: UIImage(named: "ic_tab_add"), selectedImage: UIImage(named: "ic_tab_add"))
//         icon3.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        addVC.tabBarItem = icon3
//
//        SwinjectStoryboard.defaultContainer.assembleNotification()
//        let notificationVC = sb.instantiateViewController(withIdentifier: "PPNotificationViewControllerID") as! PPNotificationViewController
//        let icon4 = UITabBarItem(title: "", image: UIImage(named: "ic_tab_notification"), selectedImage: UIImage(named: "ic_tab_notification"))
//
//        if(UIApplication.shared.applicationIconBadgeNumber != 0){
//            icon4.badgeValue = "\(UIApplication.shared.applicationIconBadgeNumber)"
//        }
//         icon4.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        notificationVC.tabBarItem = icon4
//        let nav4 = UINavigationController(rootViewController: notificationVC)
//
//        SwinjectStoryboard.defaultContainer.assembleUserProfile(userID: PixelPhotoSDK.shared.getMyUserID())
//        let myProfileVC = sb.instantiateViewController(withIdentifier: "PPMyProfileViewControllerID") as! PPMyProfileViewController
//        let icon5 = UITabBarItem(title: "", image: UIImage(named: "ic_tab_profile"), selectedImage: UIImage(named: "ic_tab_profile"))
//        myProfileVC.tabBarItem = icon5
//         icon5.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        let nav5 = UINavigationController(rootViewController: myProfileVC)
//
//        self.setViewControllers([nav1,nav2,addVC,nav4,nav5], animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tabBar.invalidateIntrinsicContentSize()
    }
//    func gotToAddPost(type:POSTTYPE){
//        SwinjectStoryboard.defaultContainer.assembleAddPost(type: type)
//        let sb = SwinjectStoryboard.create(name: "Post",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let addPostVC = sb.instantiateViewController(withIdentifier: "PPAddPostViewControllerID") as! PPAddPostViewController
//        let nav = UINavigationController(rootViewController: addPostVC)
//        addPostVC.onRefresh = {
//            if self.selectedIndex == 0 {
//                let vc =  (self.viewControllers![0] as! UINavigationController).visibleViewController as? PPHomeViewController
//                vc?.viewModel?.state.accept(DATASTATUS.INITIAL)
//            }else if self.selectedIndex == 1 {
//                let vc =  (self.viewControllers![0] as! UINavigationController).visibleViewController as? PPExploreViewController
//                vc?.viewModel?.state.accept(DATASTATUS.INITIAL)
//            }else if self.selectedIndex == 4 {
//
//            }
//        }
//        self.present(nav, animated: true, completion: nil)
//    }
//
//    @objc func itemPressed(){
//        print("Press number : \(numberOfTapped)")
//
//        if numberOfTapped > 1 {
//
//        }else{
//
//        }
//
//        numberOfTapped = 0
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


////extension PPTabBarBaseViewController : UITabBarControllerDelegate {
//
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        
//        selectedIndx = (self.tabBar.items?.index(of: item))!
//        numberOfTapped += 1
//
//        let myTimer = Timer(timeInterval: 0.7, target: self, selector: #selector(PPTabBarBaseViewController.itemPressed), userInfo: nil, repeats: false)
//        RunLoop.current.add(myTimer, forMode: RunLoop.Mode.common)
//        
//        
//    }
//    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
////       print(tabBarController.selectedIndex)
////        if tabBarController.selectedIndex != 0 {
////            (tabBarController.viewControllers![0] as! PPHomeViewController).viewModel?.pressOtherPages.accept(true)
////        }
//    }
//    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        
//        if viewController is PPAddPostSelectViewController {
//            let sb = SwinjectStoryboard.create(name: "Dashboard",
//                                               bundle: nil,
//                                               container: SwinjectStoryboard.defaultContainer)
//            let addVC = sb.instantiateViewController(withIdentifier: "PPAddPostSelectViewControllerID") as! PPAddPostSelectViewController
//            addVC.onClicked = { type in
//                self.gotToAddPost(type: type)
//            }
//            if self.parent is UINavigationController {
//                 tabBarController.navigationController!.present(addVC, animated: true, completion: nil)
//            }else{
//                 tabBarController.present(addVC, animated: true, completion: nil)
//            }
//           
//            return false
//        }
//        
//        return true
//    }
//    
//}
