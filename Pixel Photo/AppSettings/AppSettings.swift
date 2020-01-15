//
//  AppSettings.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import UIKit
struct AppConstant {
    static let key = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OalJteHhVMVJXYUZZd2JEVlVNV014VjJ4WmVtRkljRmhpUjJoTVZHeFdOR1JHVW5WWGJXeFdaVzFqTlNOV1JFWlRXVmRHY2s1WVVsZFdSVFZQVm10a01FMUdVbGxqUms1b1RVUldSVlJWVWtOWGJVWjBZek5rVlZKdFVreFpiRlUxVWxkRmVsVnJOVmROVmxZMFZqSXhkMk5yTUhkT1dGSlhWa1ZLYUZaclpHOWpaejA5UURFMU16azROelF4T0RZa01qTXpNVGc1T1RjPQ=="
}

struct ControlSettings {
    static let ShowFacebookLogin = true
    static let ShowGoogleLogin = true
    
    static let Show_ADMOB_Banner = true
    static let Show_ADMOB_Interstitial = true
    static let Show_ADMOB_RewardVideo = true
    
    static let Ad_Unit_ID = "ca-app-pub-5135691635931982/xxxx"
    static let Ad_Interstitial_Key = "ca-app-pub-51356635932/xxx"
    static let Ad_RewardVideo_Key = "ca-app-pub-51356163593/xxx"
        static let googleClientKey = "497109148599-u0g40f3e5uh53286hdrpsj10v505tral.apps.googleusercontent.com"
     static let oneSignalAppId = "e6438711-ced7-41c6-84d6-038a6076960b"
    
    
    static let Show_ADMOB_Interstitial_Count = 3
    static let Show_ADMOB_RewardedVideo_Count = 3
    
    static let RunSoundControl = false
    static let RefreshChatActivitiesSeconds = 60
    
    static let ShowNotification = true
    
    static let ShowGalleryImage = true
    static let ShowGalleryVideo = true
    static let ShowMention = true
    static let ShowCamera = true
    static let ShowGif = true
    static let ShowEmbedVideo = true
    static let ShowBio = true
    //farhadk2 change to true
    static let EnableSocialLogin = false
    
    static let ShowSettingsGeneralAccount = true
    static let ShowSettingsAccountPrivacy = true
    static let ShowSettingsPassword = true
    static let ShowSettingsBlockedUsers = true
    static let ShowSettingsNotifications = false
    static let ShowSettingsDeleteAccount = true
    
    
    
}

extension UIColor {
    
    @nonobjc class var mainColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#f65599")
    }
    
    @nonobjc class var startColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#f65599")
    }
    
    @nonobjc class var endColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#4d0316")
    }
}
