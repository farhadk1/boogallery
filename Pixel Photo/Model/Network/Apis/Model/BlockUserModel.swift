//
//  BlockUserModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation

class BlockUserModel:BaseModel{
    struct BlockUserSuccessModel: Codable {
        let code, status: String?
        let data: [Datum]?
    }
    
    struct Datum: Codable {
        let userID: Int?
        let avatar: String?
        let username, fname, lname, name: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case avatar, username, fname, lname, name
        }
    }

}
class BlockUnBlockUserModel:BaseModel{
    // MARK: - Welcome
    struct BlockUnBlockUserSuccessModel: Codable {
        let code, status: String?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let message: String?
        let code: Int?
    }

}
