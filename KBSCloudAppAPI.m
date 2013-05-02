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

  return self;
}

- (void)dealloc {
  [self clearUsernameAndPassword];
}

#pragma mark - API Calls

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block {
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
  NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"items" parameters:item];
  request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
  AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"ZZ: %@ %@", self.username, self.password);
    NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
    block(responseURL, responseObject, nil);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"XX: %@ %@", self.username, self.password);
    NSLog(@"E: %@", error);
    if (operation.response.statusCode == 403 || operation.response.statusCode == 401) {
      error = [self invalidCredentialsError];
    }
    
    block(nil, nil, error);
  }];

  [self enqueueHTTPRequestOperation:operation];
  return;
  [self postPath:@"items" parameters:item success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"ZZ: %@ %@", self.username, self.password);
    NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
    block(responseURL, responseObject, nil);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"XX: %@ %@", self.username, self.password);
    NSLog(@"E: %@", error);
    if (operation.response.statusCode == 403 || operation.response.statusCode == 401) {
      error = [self invalidCredentialsError];
    }

    block(nil, nil, error);
  }];
}

#pragma mark - Username/Password Methods

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
//  [self cancelAllHTTPOperationsWithMethod:@"POST" path:@"items"];
  [self clearUsernameAndPassword];
  _username = [name copy];
  _password = [pass copy];
  [self setDefaultCredential:[NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone]];
  
  NSDictionary *a = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
  for (NSURLProtectionSpace *c in a) {
//    NSLog(@"%@", c.host);
  }
}

- (BOOL)hasUsernameAndPassword {
  return (self.username && self.password);
}

- (void)clearUsernameAndPassword {
  _username = nil;
  _password = nil;
  [self setDefaultCredential:nil];
  [self clearCloudAppCookies];
  [self clearURLCredentials];
}

- (void)clearCloudAppCookies {
  NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:baseAPI]];
  for (NSHTTPCookie *c in cookies) {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:c];
  }
}

- (void)clearURLCredentials {
  NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] initWithHost:@"my.cl.ly" port:0 protocol:@"http" realm:nil authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
  for (NSURLCredential *cred in [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:space]) {
    [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:space];
  }
}

#pragma mark - Errors

- (NSError *)noUserOrPassError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Missing CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppNoUserOrPass userInfo:errorInfo];
}

- (NSError *)invalidCredentialsError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Invalid CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppAPIInvalidUser userInfo:errorInfo];
}

@end
