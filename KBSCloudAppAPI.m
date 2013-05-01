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
  [self setDefaultHeader:@"Accept" value:@"application/json"];
  [self setDefaultHeader:@"Content-Type" value:@"application/json"];
  [self setParameterEncoding:AFJSONParameterEncoding];

  return self;
}

#pragma mark - API Calls

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSDictionary *response, NSError *error))block {
  NSParameterAssert(url);
  NSParameterAssert(block);

  if (![self hasUserAndPass]) {
    block(nil, [self noUserOrPassError]);
    return;
  }

  NSDictionary *data = @{@"item": @{@"redirect_url": [url absoluteString], @"name": name}};
  NSLog(@"D %@", data);
//  NSURLRequest *request = [self requestWithMethod:@"POST" path:@"items" parameters:data];
//  NSLog(@"U: %@ UU: %@", request.URL, url);
  
  
//  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//    block(JSON, nil);
//  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//    block(nil, error);
//  }];
//  
//  [operation start];

  [self postPath:@"items" parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    NSLog(@"%@", responseObject);
//    NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    block(responseObject, nil);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

#pragma mark - Helper Methods

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
  self.username = [name copy];
  self.password = [pass copy];
  [self setAuthorizationHeaderWithUsername:self.username password:self.password];
}

- (void)clearUsernameAndPassword {
  self.username = nil;
  self.password = nil;
  [self clearAuthorizationHeader];
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
