//
//  CommentManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 06/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class CommentManager{
    static let instance = CommentManager()
    func getComment(accessToken:String,postId:Int,limit:Int,offset:Int, completionBlock: @escaping (_ Success:CommentModel.CommentSuccessModel?,_ SessionError:CommentModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.post_id: postId,
            API.PARAMS.limit: limit,
            API.PARAMS.offset: offset,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.POST_CONSTANT_METHODS.GET_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.POST_CONSTANT_METHODS.GET_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(CommentModel.CommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(CommentModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }

    func likeComment(accessToken:String,commentId:Int, completionBlock: @escaping (_ Success:LikeCommentModel.LikeCommentSuccessModel?,_ SessionError:LikeCommentModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.comment_id: commentId,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.POST_CONSTANT_METHODS.LIKE_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.POST_CONSTANT_METHODS.LIKE_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(LikeCommentModel.LikeCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(LikeCommentModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func addComment(accessToken:String,postId:Int,Text:String, completionBlock: @escaping (_ Success:AddCommentModel.AddCommentSuccessModel?,_ SessionError:AddCommentModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.post_id: postId,
            API.PARAMS.text: Text,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.POST_CONSTANT_METHODS.ADD_COMMENT_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.POST_CONSTANT_METHODS.ADD_COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(AddCommentModel.AddCommentSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(AddCommentModel.SessionAndServerError.self, from: data)
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
