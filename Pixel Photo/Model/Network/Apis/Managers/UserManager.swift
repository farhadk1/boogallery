//
//  UserManager.swift
//  Pixel Photo
//
//  Created by Macbook Pro on 18/10/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import Foundation
import Alamofire
import PixelPhotoSDK
class UserManager{
    
    static let instance = UserManager()
    func authenticateUser(userName: String, password: String,DeviceId:String, completionBlock: @escaping (_ Success:LoginModel.LoginSuccessModel?,_ SessionError:LoginModel.SessionAndServerError?, Error?) ->()){
        let params = [
            
            API.PARAMS.username: userName,
            API.PARAMS.password: password,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey,
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_CONSTANT_METHODS.LOGIN_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_CONSTANT_METHODS.LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.LoginSuccessModel.self, from: data)
                    log.debug("Success = \(result.status ?? "")")
                    let User_Session = [Local.USER_SESSION.Access_token:result.data?.accessToken ?? "",Local.USER_SESSION.User_id:result.data?.userID ?? 0] as! [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
}
    func registerUser(userName: String, password: String,email:String, completionBlock: @escaping (_ Success:RegisterModel.RegisterSuccessModel?,_ SessionError:RegisterModel.SessionAndServerError?, Error?) ->()){
        let params = [
            
            API.PARAMS.username: userName,
            API.PARAMS.password: password,
            API.PARAMS.conf_password: password,
            API.PARAMS.email: email,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_CONSTANT_METHODS.REGISTER_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_CONSTANT_METHODS.REGISTER_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(RegisterModel.RegisterSuccessModel.self, from: data)
                    log.debug("Success = \(result.status ?? "")")
                    let User_Session = [Local.USER_SESSION.Access_token:result.data?.accessToken ?? "",Local.USER_SESSION.User_id:result.data?.userID ?? 0] as! [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(RegisterModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func forgetPassword(email:String, completionBlock: @escaping (_ Success:ForgetPasswordModel.ForgetPasswordSuccessModel?,_ SessionError:ForgetPasswordModel.SessionAndServerError?, Error?) ->()){
        let params = [
            API.PARAMS.email: email,
            API.PARAMS.server_key: API.SERVER_KEY.serverKey
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_CONSTANT_METHODS.FORGET_PASSWORD_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_CONSTANT_METHODS.FORGET_PASSWORD_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                
                guard let apiStatus = res["code"]  as? String else {return}
                if apiStatus ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(ForgetPasswordModel.ForgetPasswordSuccessModel.self, from: data)
                    log.debug("Success = \(result.status ?? "")")
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(ForgetPasswordModel.SessionAndServerError.self, from: data)
                    log.error("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func socialLogin(provider:String,accessToken:String,googleApiKey:String?,completionBlock: @escaping (_ Success:SocialLoginModel.SocialLoginSuccessModel?,_ SessionError:SocialLoginModel.SessionAndServerError?, Error?) ->()){
        var params = [String:String]()
        if provider == API.SOCIAL_PROVIDERS.FACEBOOK{
            params = [
                API.PARAMS.provider: provider,
                API.PARAMS.access_token: accessToken,
                API.PARAMS.server_key: API.SERVER_KEY.serverKey
            ]
        }else{
            params = [
                API.PARAMS.provider : provider,
                API.PARAMS.access_token: accessToken,
                API.PARAMS.server_key: API.SERVER_KEY.serverKey

                ] as! [String : String]
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.AUTH_CONSTANT_METHODS.SOCIAL_LOGIN_API)")
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_CONSTANT_METHODS.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let code = res["code"]  as? String else {return}
                if code ==  API.ERROR_CODES.E_200{
                    log.verbose("apiStatus Int = \(code)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(SocialLoginModel.SocialLoginSuccessModel.self, from: data)
                    log.debug("Success = \(result.data?.accessToken ?? "")")
                    let User_Session = [Local.USER_SESSION.Access_token:result.data?.accessToken as Any,Local.USER_SESSION.User_id:result.data?.userID as Any] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(code)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(SocialLoginModel.SessionAndServerError.self, from: data)
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
