//
//  Enums.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 01/01/2019.
//  Copyright © 2019 DoughouzLight. All rights reserved.
//

import UIKit

enum EDITPROFILEMODE {
    case REG
    case EDIT
}

enum POSTTYPE {
    case GIF
    case YOUTUBE
    case IMAGE
    case IMAGES
    case VIDEO
    case NONE
}

enum FOLLOWERFOLLOWINGMODE {
    case FOLLOWER
    case FOLLOWING
    case MENTIONEDFOLLOWING
}

enum SETTINGPAGE {
    case GENERAL
    case CHANGEPASSWORD
    case ACCOUNTPRIVACY
    case NOTIFICATION
    case BLOCKEDUSER
    case DELETEACCOUNT
    case LOGOUT
    case NONE
}

enum POSTSOURCE {
    case GIF
    case YOUTUBE
    case IMAGE
    case IMAGES
    case VIDEO
    case VIDEOGALLERY
    case CAMERA
    case MENTIONEDCONTACTS
}

enum DATASTATUS {
    case INITIAL
    case LOADMORE
    case PULLTOREFRESH
    case NONE
}
