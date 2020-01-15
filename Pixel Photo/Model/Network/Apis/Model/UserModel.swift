//
//  UserModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class LoginModel:BaseModel{
    
    struct LoginSuccessModel: Codable {
        let code, status: String?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let userID: Int?
        let accessToken: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case accessToken = "access_token"
        }
    }

}
class RegisterModel:BaseModel{
    struct RegisterSuccessModel: Codable {
        let code, status: String?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let userID: Int?
        let accessToken, message: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case accessToken = "access_token"
            case message
        }
    }
}

class ForgetPasswordModel:BaseModel{
    struct ForgetPasswordSuccessModel: Codable {
        let code, status, message: String?
    }

}

class SocialLoginModel:BaseModel{
    struct SocialLoginSuccessModel: Codable {
        let code, status: String?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let userID: Int?
        let accessToken, message: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case accessToken = "access_token"
            case message
        }
    }
    
}
class DeleteAccountModel:BaseModel{
    struct DeleteAccountSuccessModel: Codable {
        let code, status, message: String?
    }
    
}
