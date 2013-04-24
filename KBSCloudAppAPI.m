//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudAppAPI.h"

NSString * const KBSCloudAppAPIErrorDomain = @"com.keithsmiley.cloudappapi";

static NSString * const baseAPI = @"http://my.cl.ly";

@implementation KBSCloudAppAPI

- (KBSCloudAppAPI *)sharedClient {
  static KBSCloudAppAPI *sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedClient = [[KBSCloudAppAPI alloc] initWithBaseURL:[NSURL URLWithString:baseAPI]];
  });

  return sharedClient;
}

#pragma mark - API Calls

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSDictionary *dictionary, NSError *error))block {
  NSParameterAssert(url);
  NSParameterAssert(block);

  if (![self hasUserAndPass]) {
    block(nil, [self noUserOrPassError]);
    return;
  }
}

#pragma mark - Helper Methods

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
  self.username = name;
  self.password = pass;
}

- (BOOL)hasUserAndPass {
  return (self.username && self.password);
}

#pragma mark - Errors

- (NSError *)noUserOrPassError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cloud App Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Missing Cloud App username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppNoUserOrPass userInfo:errorInfo];
}

@end
