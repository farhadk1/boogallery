//
//  FollowFollowingModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class FollowFollowingModel:BaseModel{
    
    // MARK: - Welcome
    struct FollowFollowingSuccessModel: Codable {
        let code, status: String?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let userID: Int?
        let username, email, ipAddress, fname: String?
        let lname: String?
        let gender: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let countryID: Int?
        let about: String?
        let google, facebook: String?
        let twitter: String?
        let website: String?
        let active, admin, verified: Int?
        let lastSeen, registered: String?
        let isPro, posts: Int?
        let pPrivacy, cPrivacy, nOnLike, nOnMention: String?
        let nOnComment, nOnFollow, nOnCommentLike, nOnCommentReply: String?
        let startupAvatar, startupInfo, startupFollow: Int?
        let src: String?
        let searchEngines: String?
        let mode: String?
        let deviceID, balance, wallet: String?
        let referrer, profile, businessAccount: Int?
        let paypalEmail, bName, bEmail, bPhone: String?
        let bSite, bSiteAction: String?
        let id, followerID, followingID, type: Int?
        let time, name, uname: String?
        let url: String?
        let followers, following, favourites, postsCount: Int?
        let isFollowing: Bool?
        let timeText: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case username, email
            case ipAddress = "ip_address"
            case fname, lname, gender, language, avatar, cover
            case countryID = "country_id"
            case about, google, facebook, twitter, website, active, admin, verified
            case lastSeen = "last_seen"
            case registered
            case isPro = "is_pro"
            case posts
            case pPrivacy = "p_privacy"
            case cPrivacy = "c_privacy"
            case nOnLike = "n_on_like"
            case nOnMention = "n_on_mention"
            case nOnComment = "n_on_comment"
            case nOnFollow = "n_on_follow"
            case nOnCommentLike = "n_on_comment_like"
            case nOnCommentReply = "n_on_comment_reply"
            case startupAvatar = "startup_avatar"
            case startupInfo = "startup_info"
            case startupFollow = "startup_follow"
            case src
            case searchEngines = "search_engines"
            case mode
            case deviceID = "device_id"
            case balance, wallet, referrer, profile
            case businessAccount = "business_account"
            case paypalEmail = "paypal_email"
            case bName = "b_name"
            case bEmail = "b_email"
            case bPhone = "b_phone"
            case bSite = "b_site"
            case bSiteAction = "b_site_action"
            case id
            case followerID = "follower_id"
            case followingID = "following_id"
            case type, time, name, uname, url, followers, following, favourites
            case postsCount = "posts_count"
            case isFollowing = "is_following"
            case timeText = "time_text"
        }
    }
    
    enum About: String, Codable {
        case empty = ""
        case thisIsHaris = "this is haris "
    }
    
    enum Gender: String, Codable {
        case male = "male"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case russian = "russian"
    }
    
    enum Mode: String, Codable {
        case day = "day"
    }
    
    enum Src: String, Codable {
        case empty = ""
        case facebook = "Facebook"
    }

}
