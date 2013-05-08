//
//  KBSCloudApp.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#ifndef _KBSCLOUDAPP_
#define _KBSCLOUDAPP_

#import "KBSCloudAppUser.h"
#import "KBSCloudAppAPI.h"
#import "KBSCloudAppURL.h"

NS_ENUM(NSInteger, KBSCloudAppAPIErrorCode) {
  KBSCloudAppNoUserOrPass,
  KBSCloudAppAPIInvalidUser,
  KBSCloudAppInternalError
};

static NSString * const KBSCloudAppAPIErrorDomain = @"com.keithsmiley.cloudappapi";
static NSString * const baseAPI = @"http://my.cl.ly/";
static NSString * const baseShortURL = @"cl.ly";
static NSString * const itemsPath   = @"items";
static NSString * const accountPath = @"account";

#endif
