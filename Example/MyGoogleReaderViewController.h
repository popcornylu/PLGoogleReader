//
//  PLGoogleReaderViewController.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/9/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GoogleReader.h"

@interface MyGoogleReaderViewController : UIViewController 
    <PLGoogleReaderSignInDelegate, PLGRSubscriptionDelegate>
{       
    UILabel *lbEmail;
    UILabel *lbAccessToken;
    UIButton *btnNav;
    UIButton *btnSignInNormal;
    UIButton *btnSignInOauth;
    UIButton *btnSignOut;
    UIButton *btnReload;
}

@property (nonatomic, retain) IBOutlet UILabel *lbEmail;
@property (nonatomic, retain) IBOutlet UILabel *lbAccessToken;
@property (nonatomic, retain) IBOutlet UIButton *btnNav;
@property (nonatomic, retain) IBOutlet UIButton *btnSignInNormal;
@property (nonatomic, retain) IBOutlet UIButton *btnSignInOauth;
@property (nonatomic, retain) IBOutlet UIButton *btnSignOut;
@property (nonatomic, retain) IBOutlet UIButton *btnReload;

- (IBAction)reload:(id)sender;
- (IBAction)navigate:(id)sender;

@end
