//
//  LikeModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 05/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class AddAndRemoveLikeModel:BaseModel{
    struct AddAndRemoveLikeSuccessModel: Codable {
        let code, status: String?
        let isLiked: Int?
        
        enum CodingKeys: String, CodingKey {
            case code, status
            case isLiked = "is_liked"
        }
    }
}
class GetLikesModel:BaseModel{
  
    struct GetLikesSuccessModel: Codable {
        let code, status: String?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let id, postID, userID: Int?
        let type, time, username: String?
        let avatar: String?
        let isFollowing: Int?
        let timeText, name: String?
        let userData: UserData?
        
        enum CodingKeys: String, CodingKey {
            case id
            case postID = "post_id"
            case userID = "user_id"
            case type, time, username, avatar
            case isFollowing = "is_following"
            case timeText = "time_text"
            case name
            case userData = "user_data"
        }
    }
    
    // MARK: - UserData
    struct UserData: Codable {
        let userID: Int?
        let username, email, ipAddress, password: String?
        let fname, lname, gender, emailCode: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let countryID: Int?
        let about: String?
        let google, facebook: String?
        let twitter, website: String?
        let active, admin, verified: Int?
        let lastSeen, registered: String?
        let isPro, posts: Int?
        let pPrivacy, cPrivacy, nOnLike, nOnMention: String?
        let nOnComment, nOnFollow, nOnCommentLike, nOnCommentReply: String?
        let startupAvatar, startupInfo, startupFollow: Int?
        let src, searchEngines, mode, deviceID: String?
        let balance, wallet: String?
        let referrer, profile, businessAccount: Int?
        let paypalEmail, bName, bEmail, bPhone: String?
        let bSite, bSiteAction, name, uname: String?
        let url, edit: String?
        let followers, following, favourites, postsCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case username, email
            case ipAddress = "ip_address"
            case password, fname, lname, gender
            case emailCode = "email_code"
            case language, avatar, cover
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
            case name, uname, url, edit, followers, following, favourites
            case postsCount = "posts_count"
        }
    }
}
