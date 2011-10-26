//
//  ClientLoginViewController.m
//  PLGoogleReader
//
//  Created by Popcorny on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClientLoginViewController.h"


@implementation ClientLoginViewController
@synthesize tfEmail;
@synthesize tfPassword;
@synthesize barItemLogin;
@synthesize loginBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [tfEmail release];
    [tfPassword release];
    [barItemLogin release];
    self.loginBlock = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.navigationItem.rightBarButtonItem = barItemLogin;
}

- (void)viewDidUnload
{
    [self setTfEmail:nil];
    [self setTfPassword:nil];
    [self setBarItemLogin:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)login:(id)sender {
    self.loginBlock(tfEmail.text, tfPassword.text);    
}

@end
