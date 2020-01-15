//
//  CommentModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class CommentModel:BaseModel{
    struct CommentSuccessModel: Codable {
        let code, status: String?
        let data: [Datum]?
    }
    
    // MARK: - Datum
    struct Datum: Codable {
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

}
class LikeCommentModel:BaseModel{
    struct LikeCommentSuccessModel: Codable {
        let code, status: String?
        let type: Int?
    }

    
}
class AddCommentModel:BaseModel{
    struct AddCommentSuccessModel: Codable {
        let code: String?
        let id: Int?
        let status: String?
    }
}
