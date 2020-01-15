//
//  FetchPostModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 04/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class FetchPostModel:BaseModel{
   
    struct FetchPostSuccessModel: Codable {
        let code, status: String?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let userData: DataUserData?
        let totalPosts, userFollowers, userFollowing: Int?
        let profilePrivacy, chatPrivacy, isOwner, isFollowing: Bool?
        let isReported, isBlocked, amiBlocked: Bool?
        let userPosts: [UserPost]?
        
        enum CodingKeys: String, CodingKey {
            case userData = "user_data"
            case totalPosts = "total_posts"
            case userFollowers = "user_followers"
            case userFollowing = "user_following"
            case profilePrivacy = "profile_privacy"
            case chatPrivacy = "chat_privacy"
            case isOwner = "is_owner"
            case isFollowing = "is_following"
            case isReported = "is_reported"
            case isBlocked = "is_blocked"
            case amiBlocked = "ami_blocked"
            case userPosts = "user_posts"
        }
    }
    
    // MARK: - DataUserData
    struct DataUserData: Codable {
        let userID: Int?
        let username, email, ipAddress, fname: String?
        let lname, gender, emailCode, language: String?
        let avatar, cover: String?
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
        let url: String?
        let followers, following, favourites, postsCount: Int?
        let timeText: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case username, email
            case ipAddress = "ip_address"
            case fname, lname, gender
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
            case name, uname, url, followers, following, favourites
            case postsCount = "posts_count"
            case timeText = "time_text"
        }
    }
    
    // MARK: - UserPost
    struct UserPost: Codable {
        let postID, userID: Int?
        let userPostDescription, link, youtube, vimeo: String?
        let dailymotion, playtube: String?
        let time, type, registered: String?
        let views, boosted: Int?
        let avatar: String?
        let username: String?
        let likes, votes: Int?
        let mediaSet: [MediaSet]?
        let comments: [Comment]?
        let isOwner, isLiked, isSaved, reported: Bool?
        let isVerified: Int?
        let isShouldHide: Bool?
        let userData: UserPostUserData?
        let name, timeText: String?
        
        enum CodingKeys: String, CodingKey {
            case postID = "post_id"
            case userID = "user_id"
            case userPostDescription = "description"
            case link, youtube, vimeo, dailymotion, playtube, time, type, registered, views, boosted, avatar, username, likes, votes
            case mediaSet = "media_set"
            case comments
            case isOwner = "is_owner"
            case isLiked = "is_liked"
            case isSaved = "is_saved"
            case reported
            case isVerified = "is_verified"
            case isShouldHide = "is_should_hide"
            case userData = "user_data"
            case name
            case timeText = "time_text"
        }
    }
    
    // MARK: - Comment
    struct Comment: Codable {
        let id, userID, postID: Int?
        let text, time, username: String?
        let avatar: String?
        let isOwner: Bool?
        let likes, isLiked, replies: Int?
        let timeText, name: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case postID = "post_id"
            case text, time, username, avatar
            case isOwner = "is_owner"
            case likes
            case isLiked = "is_liked"
            case replies
            case timeText = "time_text"
            case name
        }
    }
    
    // MARK: - MediaSet
    struct MediaSet: Codable {
        let id, postID, userID: Int?
        let file: String?
        let extra: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case postID = "post_id"
            case userID = "user_id"
            case file, extra
        }
    }
    
    // MARK: - UserPostUserData
    struct UserPostUserData: Codable {
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
        let followers, following: Bool?
        let favourites, postsCount: Int?
        
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
    
    // MARK: - Encode/decode helpers
    
    class JSONNull: Codable, Hashable {
        
        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }
        
        public var hashValue: Int {
            return 0
        }
        
        public init() {}
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

}


