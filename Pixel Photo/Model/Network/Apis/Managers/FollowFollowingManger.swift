//
//  FollowFollowingManger.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 28/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class FollowFollowingManager{
    static let instance = FollowFollowingManager()
    func fetchFollowers(userId:Int, accessToken:String,limit:Int,offset:Int, completionBlock: @escaping (_ Success:FollowFollowingModel.FollowFollowingSuccessModel?,_ SessionError:FollowFollowingModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.user_id: userId,
            API.PARAMS.limit: limit,
            API.PARAMS.offset: offset,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.USERS_CONSTANT_METHODS.FETCH_FOLLOWERS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.USERS_CONSTANT_METHODS.FETCH_FOLLOWERS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(FollowFollowingModel.FollowFollowingSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(FollowFollowingModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func fetchFollowings(userId:Int, accessToken:String,limit:Int,offset:Int, completionBlock: @escaping (_ Success:FollowFollowingModel.FollowFollowingSuccessModel?,_ SessionError:FollowFollowingModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.user_id: userId,
            API.PARAMS.limit: limit,
            API.PARAMS.offset: offset,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.USERS_CONSTANT_METHODS.FETCH_FOLLOWINGS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.USERS_CONSTANT_METHODS.FETCH_FOLLOWINGS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(FollowFollowingModel.FollowFollowingSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(FollowFollowingModel.SessionAndServerError.self, from: data)
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
