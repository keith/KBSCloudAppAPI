//
//  KBSCloudAppAPI.m
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudApp.h"
#import "KBSCloudAppAPI.h"

typedef void (^shortURLBlock)(NSArray *theURLs, NSArray *response, NSError *error);

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

- (void)shortenURLs:(NSArray *)urls andBlock:(void(^)(NSArray *theURLs, NSArray *response, NSError *error))block {
  NSParameterAssert(urls);
  NSParameterAssert(block);

  if (!self.user) {
    block(nil, nil, [KBSCloudAppUser missingCredentialsError]);
    return;
  }

  self.shortenReturnBlock = block;

  NSMutableArray *itemsArray = [NSMutableArray array];
  for (KBSCloudAppURL *aURL in urls) {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[aURL.originalURL absoluteString] forKey:@"redirect_url"];
    if (aURL.name) {
      [params setObject:aURL.name forKey:@"name"];
    }

    [itemsArray addObject:params];
  }

  NSDictionary *item = @{@"items": itemsArray};
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:baseAPI] URLByAppendingPathComponent:itemsPath]];
  [request setHTTPMethod:@"POST"];
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
  NSArray *responseObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];
  if (jsonError) {
    self.shortenReturnBlock(nil, nil, [self internalError]);
    return;
  }

  NSMutableArray *responseURLs = [NSMutableArray array];
  for (NSDictionary *response in responseObject) {
    NSURL *originalURL = [NSURL URLWithString:[response valueForKey:@"redirect_url"]];
    NSURL *responseURL = [NSURL URLWithString:[response valueForKey:@"url"]];
    NSString *name = [response valueForKey:@"name"];
    KBSCloudAppURL *theURL = [KBSCloudAppURL URLWithURL:originalURL andName:name andShortURL:responseURL];
    [responseURLs addObject:theURL];
  }

  self.shortenReturnBlock(responseURLs, responseObject, nil);
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

#pragma mark - Other

- (void)setUser:(KBSCloudAppUser *)user {
  [KBSCloudAppUser clearCloudAppUsers];
  _user = user;
}

- (NSError *)internalError {
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"CloudApp Error", nil), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Internal error while processing the data. Please try again.", nil)};
  return [NSError errorWithDomain:KBSCloudAppAPIErrorDomain code:KBSCloudAppInternalError userInfo: errorInfo];
}

@end

