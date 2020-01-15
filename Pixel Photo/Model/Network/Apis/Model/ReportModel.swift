//
//  ReportModel.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
class  ReportModel:BaseModel{
    struct ReportSuccessModel: Codable {
        let code, status: String?
        let type: Int?
        let message: String?
    }

}
