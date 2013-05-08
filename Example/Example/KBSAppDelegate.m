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
  NSString *username = [parts objectAtIndex:0];
  NSString *password = [parts objectAtIndex:1];
  
  KBSCloudAppUser *user = [[KBSCloudAppUser alloc] initWithUsername:username andPassword:password];
  [user isValid:^(BOOL valid, NSError *error) {
    if (valid) {
      NSLog(@"Y C: %@", user.customDomain);
    } else {
      NSLog(@"N %@", error);
      [[NSAlert alertWithError:error] runModal];
    }
  }];
  
//  KBSCloudAppAPI *api = [KBSCloudAppAPI sharedClient];
//  [api setUsername:@"" andPassword:@""];
//
//  NSURL *url = [NSURL URLWithString:@"http://github.com/"];
//  [api shortenURL:url withName:nil andBlock:^(NSURL *responseURL, NSDictionary *response, NSError *error) {
//    if (error) {
//      NSLog(@"%@", error);
//      [[NSAlert alertWithError:error] runModal];
//    } else {
//      NSLog(@"%@", responseURL);
//      NSLog(@"%@", response);
//    }
//  }];
//
//  [api hasValidAccount:^(BOOL valid, NSError *error) {
//    if (valid) {
//      NSLog(@"Is valid");
//    } else {
//      NSLog(@"Not valid %@", error);
//    }
//  }];
}

@end
