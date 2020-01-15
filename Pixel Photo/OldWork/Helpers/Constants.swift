//
//  Constants.swift
//  Pixel Photo
//
//  Created by Olivin Esguerra on 27/12/2018.
//  Copyright © 2018 Olivin Esguerra. all rights reserved.
//

import UIKit

struct APIKEYS {
    static let GOOGLEKEY = "159792036683-8f1ceh7bpp2rpcqn19v15r4ql6jt63dv.apps.googleusercontent.com"
    static let GIPHYKEY = "272Bf9XfgztAGGzdNBUL2hURvLHedN0c"
}

struct GiphyAPI  {
    static let BASEURL = "https://api.giphy.com/v1"
    static let SEARCH = "/gifs/search"
    static let TRENDING = "/gifs/trending"
    static let RANDOM = "/gifs/random"
}
struct API {
    
    static let PURCASECODE = "c99e1a62-e18e-40c7-b749-55c2bf60f5fc"
    static let SERVERKEY = "1540997286"
    
    static let BASEURL = "https://demo.pixelphotoscript.com"
    
    static let apiLogin = "/endpoints/v1/auth/login"
    static let apiSocialLogin = "/endpoints/v1/auth/social_login"
    static let apiRegister = "/endpoints/v1/auth/register"
    static let apiForgotPassword = "/endpoints/v1/auth/forget"
    static let apiLogout = "/endpoints/v1/auth/logout"
    static let apiDeleteAccount = "/endpoints/v1/auth/delete_account"
    
    
    
    static let apiReportUser = "/endpoints/v1/user/report_user"
    static let apiBlockUser = "/endpoints/v1/user/block"
    static let apiFollowUser = "/endpoints/v1/user/follow"
    static let apiGetUserFollowers = "/endpoints/v1/user/followers"
    static let apiGetUserFollowing = "/endpoints/v1/user/following"
    static let apiGetUserSuggestions = "/endpoints/v1/user/fetch_suggestions"
    static let apiGetUserNotifications = "/endpoints/v1/user/fetch_notifications"
    static let apiGetUserInfo = "/endpoints/v1/user/fetch_userdata"
    static let apiGetUserHashtag = "/endpoints/v1/user/search"
    static let apiGetUserBlocked = "/endpoints/v1/user/fetch_blocked_users"
    
    static let apiFetchComments = "/endpoints/v1/post/fetch_comments"
    static let apiFetchLikes = "/endpoints/v1/post/fetch_likes"
    static let apiFetchFeaturedPosts = "/endpoints/v1/post/fetch_featured_posts"
    static let apiPostImageImageVideoGIF = "/endpoints/v1/post/new_post"
    static let apiaddRemoveFromFavorite =  "/endpoints/v1/post/add_to_favorite"
    static let apiFetchFavoritePosts = "/endpoints/v1/post/fetch_favorites"
    static let apiFetchExplorePosts =  "/endpoints/v1/post/fetch_explore"
    static let apiFetchPostsByHashtag =  "/endpoints/v1/post/fetch_hash_posts"
    static let apiFetchUserPostsByUserId = "/endpoints/v1/post/fetch_user_posts"
    static let apiLikePost = "/endpoints/v1/post/like_post"
    static let apiaddComment = "/endpoints/v1/post/add_comment"
    static let apiDeleteComment = "/endpoints/v1/post/delete_comment"
    static let apiFetchHomePosts =  "/endpoints/v1/post/fetch_home_posts"
    static let apiReportPost = "/endpoint/v1/post/report_post"
    
    //Story
    static let apiCreateStory = "/endpoints/v1/story/create_story"
    static let apiFetchStories = "/endpoints/v1/story/fetch_stories"
    static let apiDeleteStory = "/endpoints/v1/story/delete_story"
    
    //Settings
    static let apiSaveSettings = "/endpoints/v1/settings/save_setting"
    static let apiGetSettings = "/endpoints/v1/settings/get_setting"
    
    //Messages
    static let apiGetChats = "/endpoints/v1/messages/get_chats"
    static let apiGetUserMessages =  "/endpoints/v1/messages/get_user_messages"
    static let apiSendMessage = "/endpoints/v1/messages/send_message"
    static let apiClearMessages = "/endpoints/v1/messages/clear_messages"
    static let apiDeleteChat = "/endpoints/v1/messages/delete_chat"
    static let apiDeleteMessage = "/endpoints/v1/messages/delete_message"
}

struct COLOR {
    static let DARKPINK = UIColor(red: 138.0/255.0, green: 29.0/255.0, blue: 57.0/255.0, alpha: 1.0)
}
