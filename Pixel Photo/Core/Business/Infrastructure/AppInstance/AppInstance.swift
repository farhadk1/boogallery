//
//  AppInstance.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Foundation
import Async
import UIKit
import PixelPhotoSDK

class AppInstance {
    
    // MARK: - Properties
    
    static let instance = AppInstance()
    
    var userId:Int? = nil
    var accessToken:String? = nil
    var genderText:String? = "all"
    var profilePicText:String? = "all"
    var statusText:String? = "all"
    var playSongBool:Bool? = false
    var currentIndex:Int? = 0
    var popupPlayPauseSong:Bool? = false
    var offlinePlayPauseSong:Bool? = false
    
    // MARK: -
    var userProfile:ProfileModel.ProfileSuccessModel?
    
    
    func getUserSession()->Bool{
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        if localUserSessionData.isEmpty{
            return false
        }else {
            self.userId = (localUserSessionData[Local.USER_SESSION.User_id]  as! Int)
            self.accessToken = localUserSessionData[Local.USER_SESSION.Access_token] as? String ?? ""
            return true
        }
    }
    
    func fetchUserProfile(){
        
        let status = AppInstance.instance.getUserSession()
        
        if status{
            let userId = AppInstance.instance.userId ?? 0
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                ProfileManger.instance.getProfile(userId: userId, accessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            AppInstance.instance.userProfile = success ?? nil
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.errors?.errorText ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else {
            log.error(InterNetError)
        }
    }
}
