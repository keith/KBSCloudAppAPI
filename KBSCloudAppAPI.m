//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudAppAPI.h"

NSString * const KBSCloudAppAPIErrorDomain = @"com.keithsmiley.cloudappapi";

static NSString * const baseAPI = @"http://my.cl.ly/";
static NSString *itemsPath   = @"items";
static NSString *accountPath = @"account";

typedef void (^shortURLBlock)(NSURL *shortURL, NSDictionary *response, NSError *error);
typedef void (^validAccountBlock)(BOOL valid, NSError *error);

@interface KBSCloudAppAPI ()
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *customURL;

@property (copy) shortURLBlock shortenReturnBlock;
@property (copy) validAccountBlock validAccBlock;
@end

@implementation KBSCloudAppAPI

+ (KBSCloudAppAPI *)sharedClient {
  static KBSCloudAppAPI *sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedClient = [[KBSCloudAppAPI alloc] init];
  });

  return sharedClient;
}

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  self.baseURL = [NSURL URLWithString:baseAPI];

  return self;
}

#pragma mark - API Calls

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block {
  NSParameterAssert(url);
  NSParameterAssert(block);

  if (![self hasUsernameAndPassword]) {
    block(nil, nil, [self noUserOrPassError]);
    return;
  }

  self.shortenReturnBlock = block;

  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  [data setObject:[url absoluteString] forKey:@"redirect_url"];
  if (name) {
    [data setObject:name forKey:@"name"];
  }

  NSDictionary *item = @{@"item": data};
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.baseURL URLByAppendingPathComponent:itemsPath]];
  [request setHTTPMethod:@"POST"];
  [request setHTTPShouldHandleCookies:false];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  NSError *jsonError = nil;
  NSData *httpData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&jsonError];
  if (jsonError) {
    self.shortenReturnBlock(nil, nil, jsonError);
    return;
  }

  [request setHTTPBody:httpData];

  NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
  [conn start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"F: %@", error);

  NSURLRequest *request = [connection originalRequest];
  NSURL *requestURL = [request URL];
  NSString *path = [requestURL lastPathComponent];
  if ([path isEqualToString:itemsPath] && self.shortenReturnBlock) {
    self.shortenReturnBlock(nil, nil, error);
  } else if ([path isEqualToString:accountPath] && self.validAccBlock) {
    self.validAccBlock(false, error);
  } else {
    NSLog(@"Unhandled connection Error: %@", error);
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *cred = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
  } else {
    NSURLRequest *request = [connection originalRequest];
    NSURL *requestURL = [request URL];
    NSString *path = [requestURL lastPathComponent];

    if ([path isEqualToString:itemsPath] && self.shortenReturnBlock) {
      self.shortenReturnBlock(nil, nil, [self invalidCredentialsError]);
    } else if ([path isEqualToString:accountPath] && self.validAccBlock) {
      self.validAccBlock(false, [self invalidCredentialsError]);
    } else {
      NSLog(@"Unhandled credentials error Request: %@ URL: %@", request, requestURL);
    }
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSURLRequest *request = [connection originalRequest];
  NSURL *requestURL = [request URL];
  NSString *path = [requestURL lastPathComponent];

  NSError *jsonError = nil;
  NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
  if (jsonError) {
    if ([path isEqualToString:itemsPath] && self.shortenReturnBlock) {
      self.shortenReturnBlock(nil, nil, [self internalError]);
    } else if ([path isEqualToString:accountPath] && self.validAccBlock) {
      self.validAccBlock(false, [self internalError]);
    } else {
      NSLog(@"Unhandled JSON Error: %@", jsonError);
    }
  }

  if ([path isEqualToString:itemsPath] && self.shortenReturnBlock) {
    NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
    self.shortenReturnBlock(responseURL, responseObject, nil);
  } else if ([path isEqualToString:accountPath] && self.validAccBlock) {
    NSString *customDomain = [responseObject valueForKey:@"domain"];
    NSLog(@"Custom domain %@", customDomain);
    if ((NSNull *)customDomain != [NSNull null] && customDomain) {
      self.customURL = customDomain;
    }

    self.validAccBlock(true, nil);
  } else {
    NSLog(@"Unhandled JSON Error: %@", jsonError);
  }
}

#pragma mark - Username/Password Methods

- (void)hasValidAccount:(void(^)(BOOL valid, NSError *error))block {
  NSParameterAssert(block);

  if (![self hasUsernameAndPassword]) {
    block(false, [self noUserOrPassError]);
    return;
  }

  self.validAccBlock = block;

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.baseURL URLByAppendingPathComponent:accountPath]];
  [request setHTTPMethod:@"GET"];
  [request setHTTPShouldHandleCookies:false];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
  [conn start];
}

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
  [self clearUsernameAndPassword];
  _username = [name copy];
  _password = [pass copy];
}

- (BOOL)hasUsernameAndPassword {
  return (self.username && self.password);
}

- (NSString *)usersCustomURL {
  return self.customURL;
}

- (void)clearUsernameAndPassword {
  _username = nil;
  _password = nil;
  [self clearCloudAppCookies];
}

- (void)clearCloudAppCookies {
  NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:baseAPI]];
  for (NSHTTPCookie *c in cookies) {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:c];
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

- (NSError *)internalError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Internal error while processing the data. Please try again.", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppInternalError userInfo: errorInfo];
}

@end

