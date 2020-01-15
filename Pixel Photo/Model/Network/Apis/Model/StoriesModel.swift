//
//  StoriesModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 03/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation

class FetchStoryModel:BaseModel{
    
    // MARK: - Welcome
    struct FetchStorySuccessModel: Codable {
        let code, status: String?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let id, userID: Int?
        let caption, time: String?
        let mediaFile: String?
        let type, duration, username, fname: String?
        let lname: String?
        let avatar: String?
        let new: Int?
        let newStories: String?
        let url: String?
        let name: String?
        let owner: Bool?
        let stories: [Story]?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case caption, time
            case mediaFile = "media_file"
            case type, duration, username, fname, lname, avatar, new
            case newStories = "new_stories"
            case url, name, owner, stories
        }
    }
    
    // MARK: - Story
    struct Story: Codable {
        let id, userID: Int?
        let caption, time: String?
        let mediaFile: String?
        let type, duration: String?
        let views: Int?
        let owner: Bool?
        let src: String?
        let sf: Bool?
        let timeText: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case caption, time
            case mediaFile = "media_file"
            case type, duration, views, owner, src, sf
            case timeText = "time_text"
        }
    }

}
class CreateStoryModel:BaseModel{
    
    // MARK: - Welcome
    struct CreateStorySuccessModel: Codable {
        let code, status: String?
        let id: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let message: String?
    }

}
class DeleteStoryModel:BaseModel{
    struct DeleteStorySuccessModel: Codable {
        let code, status, message: String?
    }

}
