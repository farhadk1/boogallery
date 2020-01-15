//
//  ChatModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class GetChatModel:BaseModel{
    struct GetChatSuccessModel: Codable {
        let code, status: String?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let userID: Int?
        let username: String?
        let avatar: String?
        let time: String?
        let id: Int?
        let lastMessage: String?
        let newMessage: Int?
        let timeText: String?
        let userData: UserData?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case username, avatar, time, id
            case lastMessage = "last_message"
            case newMessage = "new_message"
            case timeText = "time_text"
            case userData = "user_data"
        }
    }
    
    // MARK: - UserData
    struct UserData: Codable {
        let userID: Int?
        let username, email, ipAddress, fname: String?
        let lname, gender, language: String?
        let avatar: String?
        let cover: String?
        let countryID: Int?
        let about, google, facebook, twitter: String?
        let website: String?
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
        let url: String?
        let followers, following, favourites, postsCount: Int?
        let timeText: String?
        let isFollowing, isBlocked: Bool?
        
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
            case name, uname, url, followers, following, favourites
            case postsCount = "posts_count"
            case timeText = "time_text"
            case isFollowing = "is_following"
            case isBlocked = "is_blocked"
        }
    }
}
class GetUserChatModel:BaseModel{
    // MARK: - Welcome
    struct GetUserChatSuccessModel: Codable {
        let code, status: String
        let data: DataClass
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let cPrivacy, isBlocked, amiBlocked: Bool
        let userData: UserData
        let messages: [Message]
        
        enum CodingKeys: String, CodingKey {
            case cPrivacy = "c_privacy"
            case isBlocked = "is_blocked"
            case amiBlocked = "ami_blocked"
            case userData = "user_data"
            case messages
        }
    }
    
    // MARK: - Message
    struct Message: Codable {
        let id, fromID, toID: Int
        let text, mediaFile, mediaType, mediaName: String
        let deletedFs1, deletedFs2, seen, time: String
        let extra, timeText, position: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text
            case mediaFile = "media_file"
            case mediaType = "media_type"
            case mediaName = "media_name"
            case deletedFs1 = "deleted_fs1"
            case deletedFs2 = "deleted_fs2"
            case seen, time, extra
            case timeText = "time_text"
            case position
        }
    }
    
    // MARK: - UserData
    struct UserData: Codable {
        let userID: Int
        let username, email, ipAddress, fname: String
        let lname, gender, language: String
        let avatar: String
        let cover: String
        let countryID: Int
        let about, google, facebook, twitter: String
        let website: String
        let active, admin, verified: Int
        let lastSeen, registered: String
        let isPro, posts: Int
        let pPrivacy, cPrivacy, nOnLike, nOnMention: String
        let nOnComment, nOnFollow, nOnCommentLike, nOnCommentReply: String
        let startupAvatar, startupInfo, startupFollow: Int
        let src, searchEngines, mode, deviceID: String
        let balance, wallet: String
        let referrer, profile, businessAccount: Int
        let paypalEmail, bName, bEmail, bPhone: String
        let bSite, bSiteAction, name, uname: String
        let url: String
        let followers, following, favourites, postsCount: Int
        let timeText: String
        let isFollowing, isBlocked: Bool
        
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
            case name, uname, url, followers, following, favourites
            case postsCount = "posts_count"
            case timeText = "time_text"
            case isFollowing = "is_following"
            case isBlocked = "is_blocked"
        }
    }

}
class SendMessageModel:BaseModel{
    struct SendMessageSuccessModel: Codable {
        let code, status: String
        let data: DataClass
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let id, fromID, toID: Int
        let text, mediaFile, mediaType, mediaName: String
        let deletedFs1, deletedFs2, seen, time: String
        let extra, timeText, hashID: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text
            case mediaFile = "media_file"
            case mediaType = "media_type"
            case mediaName = "media_name"
            case deletedFs1 = "deleted_fs1"
            case deletedFs2 = "deleted_fs2"
            case seen, time, extra
            case timeText = "time_text"
            case hashID = "hash_id"
        }
    }

}
class ClearChatModel:BaseModel{
    struct ClearChatSuccessModel: Codable {
        let code, status, message: String
    }

}

class DeleteChatModel:BaseModel{
    struct DeleteChatSuccessModel: Codable {
        let code, status, message: String
    }
    
}
