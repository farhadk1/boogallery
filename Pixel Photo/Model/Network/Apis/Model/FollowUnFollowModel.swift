//
//  FollowUnFollowModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 23/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class FollowUnfollowModel:BaseModel{
    // MARK: - Welcome
    struct FollowUnfollowSuccesModel: Codable {
        let code, status: String?
        let type: Int?
    }

}
