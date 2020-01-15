//
//  UserDefaultHelper.swift
//  No Notes
//
//  Created by Olivin Esguerra on 16/10/2018.
//  Copyright © 2018 Olivin Esguerra. All rights reserved.
//

import UIKit
import KeychainSwift

protocol UserDefaultHelperModelling {
    func setAccessToken(token : String)
    func getAccessToken()->String
    
    func getHasAlreadyProfile() -> Bool
    func setHasAlreadyProfile(hasAlreadyEditProfile : String)
    
    func getHasAlreadySelectSuggestedProfile() -> Bool
    func setHasAlreadySelectSuggestedProfile(hasAlreadySelectSuggestedProfile : Bool)
    
    func getUserID() -> Int
    func setUserID(userID : Int)
    
    func setFirstInstall(isFirstInstall: Bool)
    func getFirstInstall() -> Bool
    
    func setProfileImageUrl(url: String)
    func getProfileImageUrl() -> String
    
    func setProfileFullName(fullname: String)
    func getProfileFullName() -> String
}

class UserDefaultHelper: UserDefaultHelperModelling {
    
    static let ACCESSTOKEN = "userdefaultPixelPhotoAccessToken"
    static let ALREADYEDITPROFILE = "userdefaultPixelPhotoEditProfile"
    static let ALREADYSUGGESTUSER = "userdefaultPixelPhotoSuggestUser"
    static let USERID = "userdefaultPixelPhotoUserID"
    static let PROFILEIMAGEURL = "userdefaultPixelPhotoProfileImageURL"
    static let PROFILEFULLNAME = "userdefaultPixelPhotoProfileFullName"
    static let ISFIRSTINSTALL = "userdefaultPixelPhotoIsFirstInstall"
    
    private let userdefault = UserDefaults.standard
    private let keychain = KeychainSwift()
    
    init() {
        userdefault.register(defaults: [
            UserDefaultHelper.ACCESSTOKEN : "",
            UserDefaultHelper.ALREADYEDITPROFILE : false,
            UserDefaultHelper.ALREADYSUGGESTUSER : false,
            UserDefaultHelper.USERID : "",
            UserDefaultHelper.PROFILEIMAGEURL : "",
            UserDefaultHelper.ISFIRSTINSTALL : true
        ])
    }
    
    func reset(){
        self.setProfileImageUrl(url: "")
        self.setProfileFullName(fullname: "")
        self.setAccessToken(token: "")
        self.setUserID(userID: -1)
        self.setHasAlreadyProfile(hasAlreadyEditProfile: "")
        self.setHasAlreadySelectSuggestedProfile(hasAlreadySelectSuggestedProfile: false)
    }
    
    func setProfileFullName(fullname: String) {
        userdefault.set(fullname, forKey:  UserDefaultHelper.PROFILEFULLNAME)
    }
    
    func getProfileFullName() -> String {
        return userdefault.string(forKey:  UserDefaultHelper.PROFILEFULLNAME)!
    }
    
    func setProfileImageUrl(url: String) {
        userdefault.set(url, forKey:  UserDefaultHelper.PROFILEIMAGEURL)
    }
    
    func getProfileImageUrl() -> String {
        return userdefault.string(forKey:  UserDefaultHelper.PROFILEIMAGEURL)!
    }
    
    func setFirstInstall(isFirstInstall: Bool) {
        userdefault.set(isFirstInstall, forKey:  UserDefaultHelper.ISFIRSTINSTALL)
    }
    
    func getFirstInstall() -> Bool {
        return userdefault.bool(forKey:  UserDefaultHelper.ISFIRSTINSTALL)
    }
    
    func getUserID() -> Int {
        return userdefault.integer(forKey:  UserDefaultHelper.USERID)
    }
    
    func setUserID(userID : Int) {
        userdefault.set(userID, forKey:  UserDefaultHelper.USERID)
    }
    
    func getAccessToken()->String {
        return keychain.get( UserDefaultHelper.ACCESSTOKEN)!
    }
    
    func setAccessToken(token : String) {
        keychain.set(token, forKey: UserDefaultHelper.ACCESSTOKEN)
    }
    
    func getHasAlreadyProfile() -> Bool {
          return userdefault.bool(forKey:  UserDefaultHelper.ALREADYEDITPROFILE)
    }
    
    func setHasAlreadyProfile(hasAlreadyEditProfile : String) {
       userdefault.set(hasAlreadyEditProfile, forKey:  UserDefaultHelper.ALREADYEDITPROFILE)
    }
    
    func getHasAlreadySelectSuggestedProfile() -> Bool {
        return userdefault.bool(forKey:  UserDefaultHelper.ALREADYSUGGESTUSER)
    }
    
    func setHasAlreadySelectSuggestedProfile(hasAlreadySelectSuggestedProfile : Bool) {
        userdefault.set(hasAlreadySelectSuggestedProfile, forKey:  UserDefaultHelper.ALREADYSUGGESTUSER)
    }
}
