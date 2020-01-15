//
//  FollowUnfollowManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 23/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class FollowUnFollowManager{
    static let instance = FollowUnFollowManager()
    
    func followUnFollow(accessToken:String, userId:Int,completionBlock: @escaping (_ Success:FollowUnfollowModel.FollowUnfollowSuccesModel?,_ SessionError:FollowUnfollowModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token: accessToken,
            API.PARAMS.user_id: userId,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.USERS_CONSTANT_METHODS.FOLLOW_UNFOLLOW_USERS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.USERS_CONSTANT_METHODS.FOLLOW_UNFOLLOW_USERS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(FollowUnfollowModel.FollowUnfollowSuccesModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(FollowUnfollowModel.SessionAndServerError.self, from: data)
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
