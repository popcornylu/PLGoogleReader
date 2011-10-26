//
//  ClientLoginViewController.h
//  PLGoogleReader
//
//  Created by Popcorny on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^PLClientLoginBlock)(NSString* email, NSString* password);

@interface ClientLoginViewController : UIViewController {
    
    UITextField *tfEmail;
    UITextField *tfPassword;
    UIBarButtonItem *barItemLogin;
    PLClientLoginBlock loginBlock;
}
@property (nonatomic, retain) IBOutlet UITextField *tfEmail;
@property (nonatomic, retain) IBOutlet UITextField *tfPassword;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barItemLogin;
@property (nonatomic, copy) PLClientLoginBlock loginBlock;

@end
