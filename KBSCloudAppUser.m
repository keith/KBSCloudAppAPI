//
//  KBSCloudAppUser.m
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudApp.h"
#import "KBSCloudAppUser.h"

typedef void (^validBlock)(BOOL valid, NSError *error);

@interface KBSCloudAppUser ()
@property (nonatomic, strong) NSString *password;
@property (copy) validBlock isValidBlock;
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

- (BOOL)hasCustomDomain {
  return (self.customDomain.length > 0);
}

- (NSString *)shortURLBase {
  if ([self hasCustomDomain]) {
    return self.customDomain;
  } else {
    return baseShortURL;
  }
}

- (void)isValid:(void(^)(BOOL valid, NSError *error))block {
  NSParameterAssert(block);
  self.isValidBlock = block;

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:baseAPI] URLByAppendingPathComponent:accountPath]];
  [request setHTTPMethod:@"GET"];
  [request setHTTPShouldHandleCookies:false];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
  [conn start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSError *jsonError = nil;
  NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
  NSString *customDomain = [responseObject valueForKey:@"domain"];
  if ((NSNull *)customDomain != [NSNull null] && customDomain) {
    _customDomain = customDomain;
  }

  self.isValidBlock(true, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  self.isValidBlock(false, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *cred = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
  } else {
    self.isValidBlock(false, [self invalidCredentialsError]);
  }
}

#pragma mark - Custom NSErrors

- (NSError *)invalidCredentialsError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Invalid CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppAPIInvalidUser userInfo:errorInfo];
}

@end
