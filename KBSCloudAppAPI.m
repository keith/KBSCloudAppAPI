//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudAppAPI.h"
//#import "AFJSONRequestOperation.h"

NSString * const KBSCloudAppAPIErrorDomain = @"com.keithsmiley.cloudappapi";

static NSString * const baseAPI = @"http://my.cl.ly/";
typedef void (^shortURLBlock)(NSURL *shortURL, NSDictionary *response, NSError *error);

@interface KBSCloudAppAPI ()
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (copy) shortURLBlock theReturnBlock;
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

  self.theReturnBlock = block;

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
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.baseURL URLByAppendingPathComponent:@"items"]];
  [request setHTTPMethod:@"POST"];
  [request setHTTPShouldHandleCookies:false];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  NSError *jsonError = nil;
  NSData *httpData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&jsonError];
  if (jsonError) {
    self.theReturnBlock(nil, nil, );
    return;
  }

  [request setHTTPBody:httpData];

  NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
  [conn start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"F: %@", error);
  if (self.theReturnBlock) {
    self.theReturnBlock(nil, nil, error);
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  NSLog(@"Challenge");
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *cred = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
  } else {
    if (self.theReturnBlock) {
      self.theReturnBlock(nil, nil, [self invalidCredentialsError]);
    }
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
  if (self.theReturnBlock) {
    NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
    self.theReturnBlock(responseURL, responseObject, nil);
  }
}

#pragma mark - Username/Password Methods

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
  [self clearUsernameAndPassword];
  _username = [name copy];
  _password = [pass copy];
}

- (BOOL)hasUsernameAndPassword {
  return (self.username && self.password);
}

- (void)clearUsernameAndPassword {
  _username = nil;
  _password = nil;
  [self clearCloudAppCookies];
  // [self clearURLCredentials];
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

- (NSError *)internalError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Internal error while processing the data. Please try again.", nil)}
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppInternalError userInfo: errorInfo];
}

@end
