//
//  SearchManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 07/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class SearchManager{
    
    static let instance = SearchManager()
    
    func search(accessToken:String,limit:Int,offset:Int,tagOffset:Int,keyword:String, completionBlock: @escaping (_ Success:SearchModel.SearchSuccessModel?,_ SessionError:SearchModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
//            API.PARAMS.limit: limit,
            API.PARAMS.tagoffset: tagOffset,
            API.PARAMS.word: keyword,
            API.PARAMS.offset: offset,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.USERS_CONSTANT_METHODS.SEARCH_USER_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.USERS_CONSTANT_METHODS.SEARCH_USER_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(SearchModel.SearchSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(SearchModel.SessionAndServerError.self, from: data)
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
