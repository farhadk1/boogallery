//
//  DeleteModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class DeletePostModel:BaseModel{
    struct DeletePostSuccessModel: Codable {
        let code, status, message: String?
    }

}
