//
//  FetchPostManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 04/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class FetchPostManager{
    static let instance = FetchPostManager()
    func fetchPostByUserId(accessToken:String,userId:Int,limit:Int,offset:Int, completionBlock: @escaping (_ Success:FetchPostModel.FetchPostSuccessModel?,_ SessionError:FetchPostModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            
            API.PARAMS.limit: limit,
            API.PARAMS.offset: offset,
            API.PARAMS.user_id: userId,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.POST_CONSTANT_METHODS.FETCH_POST_BY_USER_ID_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.POST_CONSTANT_METHODS.FETCH_POST_BY_USER_ID_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(FetchPostModel.FetchPostSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(FetchPostModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
