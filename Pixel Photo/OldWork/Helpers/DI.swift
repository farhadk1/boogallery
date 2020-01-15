//
//  DI.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 28/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PixelPhotoFramework

//extension Container {
//    
//    func assembleHashTagPost(items:[PostItem]){
//        self.storyboardInitCompleted(PPTagItemViewController.self) { r,c in
//            c.viewModel = r.resolve(HashTagItemViewModeling.self)!
//        }
//        
//        self.register(HashTagItemViewModeling.self) { r in
//            HashTagItemViewModel(items: items)
//        }
//    }
//    
//    func assemblePostItemByID(id:Int?){
//        
//        self.storyboardInitCompleted(PPPostItemViewController.self) { r,c in
//            c.viewModel = r.resolve(PostItemViewModeling.self)!
//        }
//        
//        self.register(PostItemViewModeling.self) { r in
//            PostItemViewModel(id:id!)
//        }
//    }
//    
//    func assemblePostItem(item: PostItem){
//        
//        self.storyboardInitCompleted(PPPostItemViewController.self) { r,c in
//            c.viewModel = r.resolve(PostItemViewModeling.self)!
//        }
//        
//        self.register(PostItemViewModeling.self) { r in
//            PostItemViewModel(itemPost: item)
//        }
//    }
//    
//    func assemblePostItem(item: BehaviorRelay<PostItem?>){
//        
//        self.storyboardInitCompleted(PPPostItemViewController.self) { r,c in
//            c.viewModel = r.resolve(PostItemViewModeling.self)!
//        }
//        
//        self.register(PostItemViewModeling.self) { r in
//            PostItemViewModel(item: item)
//        }
//    }
//    
//    func assembleSearch(){
//        
//        self.storyboardInitCompleted(SearchViewController.self) { r,c in
//            c.viewModel = r.resolve(SearchViewModeling.self)!
//        }
//        
//        self.register(SearchViewModeling.self) { r in
//            SearchViewModel()
//        }
//    }
//    
//    func assembleChatItem(user:UserModel){
//        self.storyboardInitCompleted(PPChatViewController.self) { r,c in
//            c.viewModel = r.resolve(ChatViewModeling.self)!
//        }
//        
//        self.register(ChatViewModeling.self) { r in
//            ChatViewModel(user: user)
//        }
//    }
//    
//    func assembleChatList(){
//        self.storyboardInitCompleted(PPChatListViewController.self) { r,c in
//            c.viewModel = r.resolve(ChatListViewModeling.self)!
//        }
//        
//        self.register(ChatListViewModeling.self) { r in
//            ChatListViewModel()
//        }
//    }
//    
//    func assembleTextVideoStorySubmit(fileUrl:String,isVideo:Bool){
//        
//        self.storyboardInitCompleted(PPStoryVideoSubmitViewController.self) { r,c in
//            c.viewModel = r.resolve(PPStorySubmitViewModeling.self)!
//        }
//        
//        self.register(PPStorySubmitViewModeling.self) { r in
//            PPStorySubmitViewModel(fileUrl: fileUrl, isVideo: isVideo)
//        }
//    }
//    
//    func assembleTextStorySubmit(fileUrl:String,isVideo:Bool){
//        
//        self.storyboardInitCompleted(PPStorySubmitViewController.self) { r,c in
//            c.viewModel = r.resolve(PPStorySubmitViewModeling.self)!
//        }
//        
//        self.register(PPStorySubmitViewModeling.self) { r in
//            PPStorySubmitViewModel(fileUrl: fileUrl, isVideo: isVideo)
//        }
//    }
//    
//    
//    func assembleTextStory(){
//        
//        self.storyboardInitCompleted(PPStoryTextViewController.self) { r,c in
//            c.viewModel = r.resolve(StoryTextViewModeling.self)!
//        }
//        
//        self.register(StoryTextViewModeling.self) { r in
//            StoryTextViewModel()
//        }
//    }
//    
//    func assembleWebView(url : String){
//        
//        self.storyboardInitCompleted(PPWebViewController.self) { r,c in
//            c.viewModel = r.resolve(WebViewViewModeling.self)!
//        }
//        
//        self.register(WebViewViewModeling.self) { r in
//            WebViewViewModel(url: url)
//        }
//    }
//    
//    
//    func assembleLogin(){
//        
//        self.storyboardInitCompleted(PPLoginViewController.self) { r,c in
//            c.viewModel = r.resolve(LoginViewModeling.self)!
//        }
//        
//        self.register(LoginViewModeling.self) { r in
//           LoginViewModel()
//        }
//        
//    }
//    
//    func assembleRegister(){
//        
//        self.storyboardInitCompleted(PPRegisterViewController.self) { r,c in
//            c.viewModel = r.resolve(RegisterViewModeling.self)!
//        }
//
//        
//        self.register(RegisterViewModeling.self) { r in
//            RegisterViewModel()
//        }
//        
//    }
//    
//    func assembleForgotPassword(){
//        self.storyboardInitCompleted(PPForgotPasswordViewController.self) { r,c in
//            c.viewModel = r.resolve(ForgotPasswordModeling.self)!
//        }
//
//        self.register(ForgotPasswordModeling.self) { r in
//            ForgotPasswordViewModel()
//        }
//    }
//    
//    func assembleFollowerFollowing(type:PROFILEMODE,userID:Int){
//        
//        self.storyboardInitCompleted(PPFollowerFollowingViewController.self) { r,c in
//            c.viewModel = r.resolve(FollowerFollowingViewModeling.self)!
//        }
//        
//        
//        self.register(FollowerFollowingViewModeling.self) { r in
//            FollowerFollowingViewModel(type: type, userID: userID)
//        }
//    }
//    
//    func assembleEditProfile(mode : EDITPROFILEMODE?){
//        
//        self.storyboardInitCompleted(PPEditProfileViewController.self) { r,c in
//            c.viewModel = r.resolve(EditProfileViewModeling.self)!
//        }
//        
//        self.register(EditProfileViewModeling.self) { r in
//            EditProfileViewModel(mode: mode!)
//        }
//    }
//    
//    func assembleEditProfile(user:UserModel,mode : EDITPROFILEMODE?){
//        
//        self.storyboardInitCompleted(PPEditProfileViewController.self) { r,c in
//            c.viewModel = r.resolve(EditProfileViewModeling.self)!
//        }
//        
//        self.register(EditProfileViewModeling.self) { r in
//            EditProfileViewModel(user: user,mode:mode!)
//        }
//    }
//    
//    func assembleUserSuggestion(){
//        
//        self.storyboardInitCompleted(PPSuggestionUserViewController.self) { r,c in
//            c.viewModel = r.resolve(SuggestionUserViewModeling.self)!
//        }
//        
//        self.register(SuggestionUserViewModeling.self) { r in
//            SuggestionUserViewModel()
//        }
//    }
//    
//    func assembleHomePage(){
//        self.storyboardInitCompleted(PPHomeViewController.self) { r,c in
//            c.viewModel = r.resolve(HomeViewModeling.self)!
//        }
//        
//        self.register(HomeViewModeling.self) { r in
//            HomeViewModel()
//        }
//    }
//    
//    func assembleExplorePage(){
//        
//        self.storyboardInitCompleted(PPExploreViewController.self) { r,c in
//            c.viewModel = r.resolve(ExploreViewModeling.self)!
//        }
//        
//        self.register(ExploreViewModeling.self) { r in
//            ExploreViewModel()
//        }
//    }
//    
//    func assembleComments(item : BehaviorRelay<PostItem?>){
//        
//        self.storyboardInitCompleted(PPCommentViewController.self) { r,c in
//            c.viewModel = r.resolve(CommentViewModeling.self)!
//        }
//
//        self.register(CommentViewModeling.self) { r in
//            CommentViewModel(item: item)
//        }
//    }
//    
//    func assembleFavoritePost(userID:Int){
//        
//        self.storyboardInitCompleted(PCFavoritesViewController.self) { r,c in
//            c.viewModel = r.resolve(FavoritePostViewModeling.self)!
//        }
//        
//        self.register(FavoritePostViewModeling.self) { r in
//            FavoritePostViewModel(userID: userID)
//        }
//    }
//    
//    func assembleNotification(){
//        
//        self.storyboardInitCompleted(PPNotificationViewController.self) { r,c in
//            c.viewModel = r.resolve(NotificationViewModeling.self)!
//        }
//    
//        
//        self.register(NotificationViewModeling.self) { r in
//            NotificationViewModel()
//        }
//    }
//    
//    func assembleAddPost(type:POSTTYPE){
//        
//        self.storyboardInitCompleted(PPAddPostViewController.self) { r,c in
//            c.viewModel = r.resolve(AddPostViewModeling.self)!
//            c.viewModel?.vc = c
//        }
//
//        self.register(AddPostViewModeling.self) { r in
//            AddPostViewModel(type: type)
//        }
//        
//    }
//    
//    func assembleSelectGif(gifList: BehaviorRelay<[GiphyItem]>){
//        
//        self.storyboardInitCompleted(PPSelectGIFViewController.self) { r,c in
//            c.viewModel = r.resolve(SelectGIFViewModeling.self)!
//        }
//        
//        self.register(SelectGIFViewModeling.self) { r in
//            SelectGIFViewModel(selected: gifList)
//        }
//    }
//    
//    func assembleUserProfile(userID:Int){
//        self.storyboardInitCompleted(PPMyProfileViewController.self) { r,c in
//            c.viewModel = r.resolve(ProfileViewModeling.self)!
//        }
//        
//        self.register(ProfileViewModeling.self) { r in
//            ProfileViewModel(userID: userID)
//        }
//    }
//    
//    func assembleLikesPage(postID:Int){
//        
//        self.storyboardInitCompleted(PPLikesPageViewController.self) { r,c in
//            c.viewModel = r.resolve(LikesViewModeling.self)!
//        }
//        
//        
//        self.register(LikesViewModeling.self) { r in
//            LikesViewModel(postID: postID)
//        }
//    }
//    
//    func assembileSettingAccountPrivacy(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE){
//        
//        self.storyboardInitCompleted(PPAccountPrivaicyViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingsViewModeling.self)!
//        }
//
//        
//        self.register(SettingsViewModeling.self) { r in
//            SettingsViewModel(user: user, pageType: pageType)
//        }
//    }
//    
//    func assembileSettingChangePassword(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE){
//        
//        self.storyboardInitCompleted(PPChangePasswordViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingsViewModeling.self)!
//        }
//
//        
//        self.register(SettingsViewModeling.self) { r in
//            SettingsViewModel(user: user, pageType: pageType)
//        }
//    }
//    
//    func assembileSettingBlockedUser(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE){
//        
//        self.storyboardInitCompleted(PPBlockedUsersViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingsViewModeling.self)!
//        }
//
//        
//        self.register(SettingsViewModeling.self) { r in
//            SettingsViewModel(user: user, pageType: pageType)
//        }
//    }
//    
//    func assembileSettingDeleteAccount(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE){
//        
//        self.storyboardInitCompleted(PPDeleteAccountViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingsViewModeling.self)!
//        }
//        
//        self.register(SettingsViewModeling.self) { r in
//            SettingsViewModel(user: user, pageType: pageType)
//        }
//    }
//    
//    func assembileSettingNotification(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE){
//        
//        self.storyboardInitCompleted(PPSettingNotificationViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingsViewModeling.self)!
//        }
//        
//        self.register(SettingsViewModeling.self) { r in
//            SettingsViewModel(user: user, pageType: pageType)
//        }
//    }
//    
//    func assembileSettingGeneral(user:BehaviorRelay<UserModel?>,pageType:SETTINGPAGE){
//        
//        self.storyboardInitCompleted(PPGeneralViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingsViewModeling.self)!
//        }
//
//        self.register(SettingsViewModeling.self) { r in
//            SettingsViewModel(user: user, pageType: pageType)
//        }
//    }
//    
//    func assembleSettingsList(user:UserModel){
//        
//        self.storyboardInitCompleted(PPSettingsListViewController.self) { r,c in
//            c.viewModel = r.resolve(SettingListViewModeling.self)!
//        }
//        
//        self.register(SettingListViewModeling.self) { r in
//            SettingListViewModel(user: user)
//        }
//    }
//    
//}
