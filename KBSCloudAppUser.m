//
//  KBSCloudAppUser.m
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudAppUser.h"

@interface KBSCloudAppUser ()
@property (nonatomic, strong) NSString *password;
@end

@implementation KBSCloudAppUser

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.username = [username copy];
  self.password = [password copy];

  return self;
}

- (void)setUserPassword:(NSString *)password {
  _password = [password copy];
}

- (void)isValid:(void(^)(BOOL *valid))block {
  
}

@end
