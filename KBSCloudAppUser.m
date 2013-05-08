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
@property (nonatomic, strong) NSMutableData *responseData;
@property (copy) validBlock isValidBlock;
@end

@implementation KBSCloudAppUser

+ (instancetype)userWithUsername:(NSString *)username andPassword:(NSString *)password {
  return [[KBSCloudAppUser alloc] initWithUsername:username andPassword:password];
}

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.username = [username copy];
  self.password = [password copy];

  return self;
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
  if (!(self.username && self.password)) {
    block(false, [KBSCloudAppUser missingCredentialsError]);
    return;
  }

  self.isValidBlock = block;

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:baseAPI] URLByAppendingPathComponent:accountPath]];
  [request setHTTPMethod:@"GET"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
  self.responseData = [NSMutableData data];
  [conn start];
}

#pragma mark - NSURLConnectionDelegate/NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:nil];
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
    self.isValidBlock(false, [KBSCloudAppUser invalidCredentialsError]);
  }
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[KBSCloudAppUser class]]) {
    return false;
  }

  KBSCloudAppUser *other = (KBSCloudAppUser *)object;
  if ([self.username isEqualToString:other.username] && [self.password isEqualToString:other.password]) {
    return true;
  }
  
  return false;
}

- (BOOL)isEqualTo:(id)object {
  return [self isEqual:object];
}

#pragma mark - Class Methods

+ (void)clearCloudAppUsers {
  NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:baseAPI]];
  for (NSHTTPCookie *c in cookies) {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:c];
  }
}

+ (NSError *)invalidCredentialsError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Invalid CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppAPIInvalidUser userInfo:errorInfo];
}

+ (NSError *)missingCredentialsError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Missing CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppNoUserOrPass userInfo:errorInfo];
}

@end
