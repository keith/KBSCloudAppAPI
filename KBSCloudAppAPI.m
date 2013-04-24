//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudAppAPI.h"

@implementation KBSCloudAppAPI

- (KBSCloudAppAPI *)sharedAPI {
  static KBSCloudAppAPI *sharedAPI = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedAPI = [[KBSCloudAppAPI alloc] init];
  });

  return sharedAPI;
}

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  return self;
}

@end
