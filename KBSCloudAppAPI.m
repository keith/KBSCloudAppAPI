//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudApp.h"
#import "KBSCloudAppAPI.h"

typedef void (^shortURLBlock)(NSURL *shortURL, NSDictionary *response, NSError *error);

@interface KBSCloudAppAPI ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (copy) shortURLBlock shortenReturnBlock;
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

#pragma mark - API Calls

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block {
  NSParameterAssert(url);
  NSParameterAssert(block);

  if (!self.user) {
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
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:baseAPI] URLByAppendingPathComponent:itemsPath]];
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
  self.responseData = [NSMutableData data];
  [conn start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSError *jsonError = nil;
  NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];
  if (jsonError) {
    self.shortenReturnBlock(nil, nil, [self internalError]);
    return;
  }

  NSURL *responseURL = [NSURL URLWithString:[responseObject valueForKey:@"url"]];
  self.shortenReturnBlock(responseURL, responseObject, nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  self.shortenReturnBlock(nil, nil, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *cred = [NSURLCredential credentialWithUser:self.user.username password:self.user.password persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
  } else {
    self.shortenReturnBlock(nil, nil, [KBSCloudAppUser invalidCredentialsError]);
  }
}

#pragma mark - Errors

- (NSError *)noUserOrPassError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Missing CloudApp username or password", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppNoUserOrPass userInfo:errorInfo];
}


- (NSError *)internalError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Internal error while processing the data. Please try again.", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppInternalError userInfo: errorInfo];
}

@end

