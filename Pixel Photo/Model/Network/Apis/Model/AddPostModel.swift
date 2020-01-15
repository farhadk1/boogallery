//
//  AddPostModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 15/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class AddToPostModel:BaseModel{
    struct AddToPostSuccessModel: Codable {
        let code, status: String?
        let id: Int?
        let message: String?
    }
}
