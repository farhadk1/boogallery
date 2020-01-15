//
//  SearchModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 07/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class SearchModel:BaseModel{
    
    struct  SearchSuccessModel: Codable {
        let code, status: String?
        let data: DataClass?
    }
    
    struct DataClass: Codable {
        var users: [User]?
        var hash: [Hash]?
    }
    
    struct Hash: Codable {
        let id: Int?
        let hash, tag, lastTrendTime: String?
        let useNum: Int?
        
        enum CodingKeys: String, CodingKey {
            case id, hash, tag
            case lastTrendTime = "last_trend_time"
            case useNum = "use_num"
        }
    }
    
    // MARK: - User
    struct User: Codable {
        let userID: Int?
        let username, email, ipAddress, fname: String?
        let lname: String?
        let gender: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let countryID: Int?
        let about, google, facebook, twitter: String?
        let website: String?
        let active, admin, verified: Int?
        let lastSeen: String?
        let registered: String?
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
        let bSite, bSiteAction, name, uname: String?
        let url: String?
        let followers, following, favourites, postsCount: Int?
        let timeText: String?
        let isFollowing: CountViews?
        
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
        }
    }
    
    enum Gender: String, Codable {
        case female = "female"
        case male = "male"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case french = "french"
    }
    
    enum Mode: String, Codable {
        case day = "day"
    }
    
    enum Registered: String, Codable {
        case the00000 = "0000/0"
        case the20187 = "2018/7"
    }
    
    enum Src: String, Codable {
        case empty = ""
        case facebook = "Facebook"
    }
    enum CountViews: Codable {
        case integer(Int)
        case bool(Bool)
        
        var BoolValue : Bool? {
            guard case let .bool(value) = self else { return nil }
            return value
        }
        
        var intValue : Int? {
            guard case let .integer(value) = self else { return nil }
            return value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self = .integer(x)
                return
            }
            if let x = try? container.decode(Bool.self) {
                self = .bool(x)
                return
            }
            throw DecodingError.typeMismatch(CountViews.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .integer(let x):
                try container.encode(x)
            case .bool(let x):
                try container.encode(x)
            }
        }
    }
}
