
//
//  Protocols.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PixelPhotoFramework

protocol HasGetComment {
    var getComment : BehaviorRelay<BehaviorRelay<PostItem?>?> { get set }
}

protocol HasReportPost {
    var reportPost : BehaviorRelay<PostItem?> { get set }
}

protocol HasDeletePost {
    var deletePost : BehaviorRelay<PostItem?> { get set }
}

protocol HasGetProfile {
    var selectUserItem: BehaviorRelay<Int?> { get set }
}

protocol NeedsToInitialize {
    var isInitialize : BehaviorRelay<Bool> { get set }
}

protocol ShouldGoBack {
    var goBack : BehaviorRelay<Bool> { get set }
}

protocol HasLoadmoreAndPulltoRefresh {
    var offset : Int { get set }
    var state : BehaviorRelay<DATASTATUS> { get set }
    var finishedInfiniteScroll : BehaviorRelay<Bool> { get set }
    var finishedPullToRefresh: BehaviorRelay<Bool> { get set }
}

protocol BaseViewModelling {
    var onErrorTrigger : BehaviorRelay<(String,String)> { get set }
}

protocol Submitable {
    var submitButton : BehaviorRelay<Bool> { get set }
}

protocol LoginViewModeling : BaseViewModelling, Submitable {
    var userNameText : BehaviorRelay<String> { get set }
    var passwordText : BehaviorRelay<String> { get set }
    var deviceId : BehaviorRelay<String> { get set }
    var fbCred: BehaviorRelay<(String)> { get set }
    var googleCred: BehaviorRelay<(String)> { get set }
    var toEditPage : BehaviorRelay<Bool> { get set }
    var toDashboard : BehaviorRelay<Bool> { get set }
}

protocol RegisterViewModeling : BaseViewModelling, Submitable {
    var emailText : BehaviorRelay<String> { get set }
    var passwordText : BehaviorRelay<String> { get set }
    var usernameTxt : BehaviorRelay<String> { get set }
    var confirmPasswordText : BehaviorRelay<String> { get set }
    var toEditPage : BehaviorRelay<Bool> { get set }
    var deviceId : BehaviorRelay<String> { get set}
    
}

protocol ForgotPasswordModeling : BaseViewModelling , Submitable{
    var emailText : BehaviorRelay<String> { get set }
}

protocol EditProfileViewModeling: BaseViewModelling , Submitable {
    var fnameTxt : BehaviorRelay<String> { get set }
    var lnameTxt : BehaviorRelay<String> { get set }
    var aboutTxt : BehaviorRelay<String> { get set }
    var genderTxt : BehaviorRelay<String> { get set }
    var fbUrlTxt : BehaviorRelay<String> { get set }
    var googleUrlTxt : BehaviorRelay<String> { get set }
    var profileImage : BehaviorRelay<UIImage?> { get set }
    var profileUrl : BehaviorRelay<String> { get set }
    var goToSuggestionUserPage : BehaviorRelay<Bool> { get set }
    var user : UserModel? { get set }
    var mode : EDITPROFILEMODE? { get set }
    
}

protocol SuggestionUserViewModeling : BaseViewModelling , HasLoadmoreAndPulltoRefresh {
    var getUserSuggestion : BehaviorRelay<Bool> { get set }
    var userList: BehaviorRelay<[UserModel]> { get set }

    func followUnfollowUser(user : UserModel)->Observable<Bool>
}

protocol WebViewViewModeling {
    var url : String!{ get set }
}

protocol CanGoToAddPost {
    func goToAddPost()
}
