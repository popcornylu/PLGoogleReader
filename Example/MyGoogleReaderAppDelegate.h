//
//  PLGoogleReaderAppDelegate.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/9/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyGoogleReaderViewController;

@interface MyGoogleReaderAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MyGoogleReaderViewController *viewController;

@end
