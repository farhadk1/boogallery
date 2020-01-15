//
//  ProfileManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK

class ProfileManger{
    static let instance = ProfileManger()
    func getProfile(userId:Int,accessToken:String, completionBlock: @escaping (_ Success:ProfileModel.ProfileSuccessModel?,_ SessionError:ProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            
            API.PARAMS.user_id: userId,
            API.PARAMS.access_token: accessToken,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.USERS_CONSTANT_METHODS.FETCH_USER_DATA_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.USERS_CONSTANT_METHODS.FETCH_USER_DATA_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(ProfileModel.ProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(ProfileModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
}
   
    func updateUserProfile(accessToken: String,firstname:String,lastname:String,gender:String,about:String,facebook:String,google:String,avatar_data:Data?, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.fname : firstname,
            API.PARAMS.lname : lastname,
            API.PARAMS.gender :gender,
            API.PARAMS.about : about,
            API.PARAMS.facebook : facebook,
            API.PARAMS.google : google,
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
          
                if let data = avatar_data{
                    multipartFormData.append(data, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/png")
                }
        }, usingThreshold: UInt64.init(), to: API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, headers: headers) { (result) in
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
                            let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                            log.debug("Success = \(result.message ?? nil)")
                            completionBlock(result,nil,nil)
                        }else{
                            log.verbose("apiStatus String = \(apiStatus)")
                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                            let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
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
    func updateAvatar(accessToken: String,avatar_data:Data?, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
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
            
            if let data = avatar_data{
                multipartFormData.append(data, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, headers: headers) { (result) in
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
                            let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                            log.debug("Success = \(result.message ?? nil)")
                            completionBlock(result,nil,nil)
                        }else{
                            log.verbose("apiStatus String = \(apiStatus)")
                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                            let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
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
    func updateGeneral(accessToken: String,username:String,email:String,gender:String, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.username : username,
            API.PARAMS.email : email,
            API.PARAMS.gender :gender,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func changePassword(accessToken: String,currentPassword:String,newPassword:String,confirmPassword:String, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.old_password : currentPassword,
            API.PARAMS.new_password : newPassword,
            API.PARAMS.conf_password :confirmPassword,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func removeAccount(accessToken: String,password:String, completionBlock: @escaping (_ Success:DeleteAccountModel.DeleteAccountSuccessModel?,_ AuthError:DeleteAccountModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.password : password,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_CONSTANT_METHODS.DELETE_ACCOUNT_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_CONSTANT_METHODS.DELETE_ACCOUNT_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(DeleteAccountModel.DeleteAccountSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(DeleteAccountModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func updateEditProfile(accessToken: String,firsName:String,lastName:String,about:String,facebook:String,google:String,twitter:String, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.fname : firsName,
            API.PARAMS.lname : lastName,
            API.PARAMS.about :about,
            API.PARAMS.facebook : facebook,
            API.PARAMS.google : google,
            API.PARAMS.twitter :twitter,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func updateAccPrivacy(accessToken: String,profilePrivacy:String,messagePrivacy:String,searchEngine:String, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.p_privacy : profilePrivacy,
            API.PARAMS.c_privacy : messagePrivacy,
            API.PARAMS.search_engines : searchEngine,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func updateNotificationSettings(accessToken: String,onLike:String,onComment:String,Follow:String,mention:String, completionBlock: @escaping (_ Success:UpdateProfileModel.UpdateProfileSuccessModel?,_ AuthError:UpdateProfileModel.SessionAndServerError?, Error?) ->()){
        
        let params = [
            API.PARAMS.access_token : accessToken,
            API.PARAMS.n_on_like : onLike,
            API.PARAMS.n_on_comment : onComment,
            API.PARAMS.n_on_follow : Follow,
             API.PARAMS.n_on_mention : mention,
            API.PARAMS.server_key : API.SERVER_KEY.serverKey
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.SETTING_CONSTANT_METHODS.SAVE_SETTINGS_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.UpdateProfileSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UpdateProfileModel.SessionAndServerError.self, from: data)
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
