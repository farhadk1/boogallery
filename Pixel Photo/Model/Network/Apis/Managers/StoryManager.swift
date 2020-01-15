//
//  StoryManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 03/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class StoryManager{
    static let instance = StoryManager()
    func FetchStory(accessToken:String, completionBlock: @escaping (_ Success:FetchStoryModel.FetchStorySuccessModel?,_ SessionError:FetchStoryModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.STORY_CONSTANT_METHODS.FETCH_STORIES_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.STORY_CONSTANT_METHODS.FETCH_STORIES_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(FetchStoryModel.FetchStorySuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(FetchStoryModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func createStory(accessToken: String,story_data:Data?,mimeType:String,type:String,text:String, completionBlock: @escaping (_ Success:CreateStoryModel.CreateStorySuccessModel?,_ AuthError:CreateStoryModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.text : text,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if type == "video"{
                if let data = story_data{
                    multipartFormData.append(data, withName: "file", fileName: "file.mp4", mimeType: mimeType)
                }
            }else if type == "image"{
                if let data = story_data{
                     multipartFormData.append(data, withName: "file", fileName: "image.jpg", mimeType: mimeType)
                }
            }
           
        }, usingThreshold: UInt64.init(), to: API.STORY_CONSTANT_METHODS.CREATE_STORY_API, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    log.verbose("response = \(response.result.value)")
                    if (response.result.value != nil){
                        guard let res = response.result.value as? [String:Any] else {return}
                        log.verbose("Response = \(res)")
                        guard let apiStatus = res["code"]  as? String else {return}
                        if apiStatus ==  API.ERROR_CODES.E_200{
                            log.verbose("apiStatus Int = \(apiStatus)")
                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                            let result = try! JSONDecoder().decode(CreateStoryModel.CreateStorySuccessModel.self, from: data)
                            log.debug("Success = \(result.data?.message ?? nil)")
                            completionBlock(result,nil,nil)
                        }else{
                            log.verbose("apiStatus String = \(apiStatus)")
                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                            let result = try! JSONDecoder().decode(CreateStoryModel.SessionAndServerError.self, from: data)
                            log.error("AuthError = \(result.errors!.errorText)")
                            completionBlock(nil,result,nil)
                            
                        }
                        
                    }else{
                        log.error("error = \(response.error?.localizedDescription)")
                        completionBlock(nil,nil,response.error)
                    }
                    
                }
            case .failure(let error):
                log.verbose("Error in upload: \(error.localizedDescription)")
                completionBlock(nil,nil,error)
                
            }
        }
    }
    func deleteStory(accessToken:String,storyId:Int, completionBlock: @escaping (_ Success:DeleteStoryModel.DeleteStorySuccessModel?,_ SessionError:DeleteStoryModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
             API.PARAMS.story_id: storyId,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.STORY_CONSTANT_METHODS.DELETE_STORY_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.STORY_CONSTANT_METHODS.DELETE_STORY_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(DeleteStoryModel.DeleteStorySuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(DeleteStoryModel.SessionAndServerError.self, from: data)
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
