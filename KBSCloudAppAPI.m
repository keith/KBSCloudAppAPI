//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudAppAPI.h"
#import "AFJSONRequestOperation.h"

NSString * const KBSCloudAppAPIErrorDomain = @"com.keithsmiley.cloudappapi";

static NSString * const baseAPI = @"http://my.cl.ly";

@interface KBSCloudAppAPI ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation KBSCloudAppAPI

+ (KBSCloudAppAPI *)sharedClient {
  static KBSCloudAppAPI *sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedClient = [[KBSCloudAppAPI alloc] initWithBaseURL:[NSURL URLWithString:baseAPI]];
  });

  return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }

  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [self setParameterEncoding:AFJSONParameterEncoding];
  [self setDefaultHeader:@"Accept" value:@"application/json"];
  [self setDefaultHeader:@"Content-Type" value:@"application/json"];

  return self;
}

- (void)dealloc {
  [self clearUsernameAndPassword];
}

#pragma mark - API Calls

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSURL *url, NSDictionary *response, NSError *error))block {
  NSParameterAssert(url);
  NSParameterAssert(block);

  if (![self hasUsernameAndPassword]) {
    block(nil, nil, [self noUserOrPassError]);
    return;
  }

  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  [data setObject:[url absoluteString] forKey:@"redirect_url"];
  if (name) {
    [data setObject:name forKey:@"name"];
  }
  
  NSDictionary *item = @{@"item": data};
  [self postPath:@"items" parameters:item success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
    block(responseURL, responseObject, nil);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    block(nil, nil, error);
  }];
}

#pragma mark - Username/Password Methods

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
  [self clearUsernameAndPassword];
  self.username = [name copy];
  self.password = [pass copy];
  [self setAuthorizationHeaderWithUsername:self.username password:self.password];
}

- (void)clearUsernameAndPassword {
  self.username = nil;
  self.password = nil;
  [self clearAuthorizationHeader];
}

- (BOOL)hasUsernameAndPassword {
  return (self.username && self.password);
}

#pragma mark - Errors

- (NSError *)noUserOrPassError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Missing CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppNoUserOrPass userInfo:errorInfo];
}

@end
