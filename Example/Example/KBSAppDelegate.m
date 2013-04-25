//
//  KBSAppDelegate.m
//  Example
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSAppDelegate.h"
#import "KBSCloudAppAPI.h"

@implementation KBSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  KBSCloudAppAPI *api = [KBSCloudAppAPI sharedClient];
  [api setUsername:@"username" andPassword:@"password"];
  NSURL *url = [NSURL URLWithString:@"http://github.com"];
  [api shortenURL:url withName:@"Github" andBlock:^(NSString *response, NSError *error) {
    if (error) {
      NSLog(@"%@", error);
    } else {
      NSLog(@"%@", [response class]);
      NSData *JSONData = [response dataUsingEncoding:NSUTF8StringEncoding];
      NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil]);
    }
  }];
}

@end
