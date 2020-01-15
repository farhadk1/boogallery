//
//  GIFManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/11/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class GIFManager{
    
    static let instance = GIFManager()
    
    func getGIFS(limit:Int,offset:Int, completionBlock: @escaping (_ Success:GIFModel.GIFSuccessModel?,_ SessionError:GIFModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            //            API.PARAMS.limit: limit,
            API.PARAMS.api_key: "b9427ca5441b4f599efa901f195c9f58",
            API.PARAMS.q: limit
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.GIF_CONSTANT_METHODS.FETCH_GIFS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.GIF_CONSTANT_METHODS.FETCH_GIFS_API, method: .get, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
         
                let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                let result = try! JSONDecoder().decode(GIFModel.GIFSuccessModel.self, from: response.data!)
                completionBlock(result,nil,nil)

            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
}
