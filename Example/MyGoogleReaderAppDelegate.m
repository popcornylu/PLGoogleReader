//
//  PLGoogleReaderAppDelegate.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/9/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "MyGoogleReaderAppDelegate.h"

#import "MyGoogleReaderViewController.h"

@implementation MyGoogleReaderAppDelegate

@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController* navController = 
        [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];     
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
