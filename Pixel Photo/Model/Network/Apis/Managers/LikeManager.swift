//
//  LikeManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 05/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class LikeManager{
    static let instance = LikeManager()
    func addAndRemoveLike(accessToken:String,postId:Int, completionBlock: @escaping (_ Success:AddAndRemoveLikeModel.AddAndRemoveLikeSuccessModel?,_ SessionError:AddAndRemoveLikeModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.post_id: postId,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.POST_CONSTANT_METHODS.ADD_AND_REMOVE_LIKE_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.POST_CONSTANT_METHODS.ADD_AND_REMOVE_LIKE_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(AddAndRemoveLikeModel.AddAndRemoveLikeSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(AddAndRemoveLikeModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func getLike(accessToken:String,postId:Int,limit:Int,offset:Int, completionBlock: @escaping (_ Success:GetLikesModel.GetLikesSuccessModel?,_ SessionError:GetLikesModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.post_id: postId,
             API.PARAMS.limit: limit,
             API.PARAMS.offset: offset,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.POST_CONSTANT_METHODS.GET_LIKES_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.POST_CONSTANT_METHODS.GET_LIKES_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(GetLikesModel.GetLikesSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(GetLikesModel.SessionAndServerError.self, from: data)
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
