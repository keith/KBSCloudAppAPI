//
//  KBSAppDelegate.m
//  Example
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSAppDelegate.h"
#import "KBSCloudApp.h"

@implementation KBSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSString *token = [[[NSProcessInfo processInfo] environment] objectForKey:@"CLOUD_CREDENTIALS"];
  NSArray *parts = [token componentsSeparatedByString:@":"];
  NSString *username = [parts objectAtIndex:0]; // Enter a valid username here
  NSString *password = [parts objectAtIndex:1]; // Enter a valid password here
  
  KBSCloudAppUser *user = [[KBSCloudAppUser alloc] initWithUsername:username andPassword:password];
  [user isValid:^(BOOL valid, NSError *error) {
    if (valid) {
      NSLog(@"Valid user");

      KBSCloudAppAPI *api = [KBSCloudAppAPI sharedClient];
      [api setUser:user];
      KBSCloudAppURL *url = [KBSCloudAppURL URLWithURL:[NSURL URLWithString:@"http://github.com/"]];
      [api shortenURLs:@[url] andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {
        if (error) {
          NSLog(@"Error shortening URL: %@", error);
        } else {
          KBSCloudAppURL *theURL = [theURLs objectAtIndex:0];
          NSLog(@"URL Shortened, short URL: %@", theURL.shortURL);
        }
      }];
    } else {
      NSLog(@"Invalid user/error: %@", error);
    }
  }];
}

@end
