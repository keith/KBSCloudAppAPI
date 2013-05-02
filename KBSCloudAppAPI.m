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

@interface KBSCloudAppAPI ()
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation KBSCloudAppAPI

+ (KBSCloudAppAPI *)sharedClient {
  static KBSCloudAppAPI *sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
//    sharedClient = [[KBSCloudAppAPI alloc] initWithBaseURL:[NSURL URLWithString:baseAPI]];
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

//  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//  [self setParameterEncoding:AFJSONParameterEncoding];
//  [self setDefaultHeader:@"Accept" value:@"application/json"];

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
//  NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"items" parameters:item];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.baseURL URLByAppendingPathComponent:@"items"]];
  NSLog(@"%@", [self.baseURL URLByAppendingPathComponent:@"items"]);
//  request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
  [request setHTTPMethod:@"POST"];
  [request setHTTPShouldHandleCookies:false];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  NSError *jsonError = nil;
  [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:item options:0 error:&jsonError]];
  
  if (jsonError)
    NSLog(@"JE: %@", jsonError);
  
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//  NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
  
  [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    if (error) {
      NSLog(@"EE: %@", error);
    } else {
      NSLog(@"NE");
    }
  }];
//  [conn start];
  
  return;
  [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

    if (error) {
        NSLog(@"E: %@", error);
    } else {
      NSLog(@"R: %@", response);
      NSError *e = nil;
      NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:&e]);
      if (e) {
        NSLog(@"EE %@", e);
      }
    }

  }];
//  [conn start];
  
  
  return;
//  [self postPath:@"items" parameters:item success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    NSLog(@"ZZ: %@ %@", self.username, self.password);
//    NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
//    block(responseURL, responseObject, nil);
//  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    NSLog(@"XX: %@ %@", self.username, self.password);
//    NSLog(@"E: %@", error);
//    if (operation.response.statusCode == 403 || operation.response.statusCode == 401) {
//      error = [self invalidCredentialsError];
//    }
//
//    block(nil, nil, error);
//  }];
}

#pragma mark - NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSLog(@"Finished: %@", connection);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"F: %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  NSLog(@"Challenge");
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *cred = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSLog(@"R %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]);
}

#pragma mark - Username/Password Methods

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass {
//  [self cancelAllHTTPOperationsWithMethod:@"POST" path:@"items"];
  [self clearUsernameAndPassword];
  _username = [name copy];
  _password = [pass copy];
//  [self setDefaultCredential:[NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone]];
  
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
//  [self setDefaultCredential:nil];
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
