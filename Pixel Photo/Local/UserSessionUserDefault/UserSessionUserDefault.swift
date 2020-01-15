//
//  UserSessionUserDefault.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import PixelPhotoSDK

enum UserDefaultsKeys : String {
    case isLoggedIn
    case userID
}

extension UserDefaults{
    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }
    
    func isLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: Save User Data
    func setUserSession(value: [String:Any], ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    func getUserSessions(Key:String) -> [String:Any]{
        return (object(forKey: Key) as? [String:Any]) ?? [:]
    }
    func setPassword(value: String, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    
    func getPassword(Key:String) ->  String{
        return object(forKey: Key)  as?  String ?? ""
    }
    func clearUserDefaults(){
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    func removeValuefromUserdefault(Key:String){
        removeObject(forKey: Key)
    }
}
