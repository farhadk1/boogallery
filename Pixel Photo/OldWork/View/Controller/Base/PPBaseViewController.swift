//
//  PPBaseViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 22/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import PixelPhotoFramework
import MessageUI
import RxCocoa
import RxSwift

extension UIViewController : MFMailComposeViewControllerDelegate {
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: NSError?) {
        controller.dismiss(animated: true)
    }
}

class PPBaseViewController: UIViewController {
    
    let sdk = PixelPhotoSDK.shared.authProvider
    var dispose =  DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func showUserProfile(userID:Int){
//        SwinjectStoryboard.defaultContainer.assembleUserProfile(userID: userID)
//        let sb = SwinjectStoryboard.create(name: "Dashboard",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let nextVC = sb.instantiateViewController(withIdentifier: "PPMyProfileViewControllerID") as! PPMyProfileViewController
//        nextVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func getCommentFromPostID(item : BehaviorRelay<PostItem?>){
//        SwinjectStoryboard.defaultContainer.assembleComments(item: item)
//        let sb = SwinjectStoryboard.create(name: "Post",
//                                           bundle: nil,
//                                           container: SwinjectStoryboard.defaultContainer)
//        let nextVC = sb.instantiateViewController(withIdentifier: "PPCommentViewControllerID") as! PPCommentViewController
//        nextVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func logout(){
        (sdk.rx_logout()
            .catchError({ (error) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse(status: "400", message: error.localizedDescription))
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext : { _ in
                PixelPhotoSDK.shared.userDefaultHelper.reset()
                let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PPIntroViewControllerID") as! PPIntroViewController
                let nav = UINavigationController(rootViewController: nextVC)
                nav.isNavigationBarHidden = true
                appDel.window?.rootViewController = nav
            }).disposed(by: self.dispose))
        

    }
    
    func sharePost(item : PostItem){
        let alertController = UIAlertController(title: "Where do you want to share it?", message: "Please choose.", preferredStyle: .actionSheet)
        
        let shareURL = item.media_set![0].file!
        
        let action1 = UIAlertAction(title: "Email", style: .default) { (action:UIAlertAction) in
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([""])
                mail.setSubject("Please See My Post")
                
                mail.setMessageBody(shareURL, isHTML: false)
                
                self.present(mail, animated: true)
            }else{
                alertController.dismiss(animated: true, completion: nil)
            }
        }
        
        let action2 = UIAlertAction(title: "Others", style: .default) { (action:UIAlertAction) in
            
            let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList,
                                                            UIActivity.ActivityType.airDrop,
                                                            UIActivity.ActivityType.assignToContact,
                                                            UIActivity.ActivityType.copyToPasteboard,
                                                            UIActivity.ActivityType.mail,
                                                            UIActivity.ActivityType.message,
                                                            UIActivity.ActivityType.openInIBooks,
                                                            UIActivity.ActivityType.print,
                                                            UIActivity.ActivityType.saveToCameraRoll,
                                                            UIActivity.ActivityType.postToTwitter,
                                                            UIActivity.ActivityType.postToFacebook]
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }


}
