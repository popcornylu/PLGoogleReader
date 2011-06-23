//
//  PLGoogleReaderViewController.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/9/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "MyGoogleReaderViewController.h"
#import "CategoryViewController.h"

@interface MyGoogleReaderViewController ()
- (void)updateUI;
@end

@implementation MyGoogleReaderViewController
@synthesize lbEmail;
@synthesize lbAccessToken;
@synthesize btnNav;
@synthesize btnSignInOut;

#pragma mark NSObject
- (void)dealloc
{
    [lbEmail release];
    [lbAccessToken release];
    [btnNav release];
    [btnSignInOut release];
    [super dealloc];
}

#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
    
    PLGRSubscription* subscription = [[PLGoogleReader defaultGoogleReader] subscription];
    if(![subscription isLoaded])
    {
        [subscription reload:self];
    }
}


- (void)viewDidUnload
{
    [self setLbEmail:nil];
    [self setLbAccessToken:nil];
    [self setBtnNav:nil];
    [self setBtnSignInOut:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Private
- (void)updateUI
{
    PLGoogleReader* googleReader =[PLGoogleReader defaultGoogleReader];
    
    lbEmail.text       = [googleReader userEmail];
    lbAccessToken.text = [googleReader accessToken];

    [btnSignInOut setTitle:[googleReader isSignedIn]?  @"Sign out" : @"Sign in"
                  forState:UIControlStateNormal];    
    
    btnNav.hidden = ![[googleReader subscription] isLoaded];
}

#pragma mark Actions
- (IBAction)signInOut:(id)sender {
    if([[PLGoogleReader defaultGoogleReader] isSignedIn])
    {
        [[PLGoogleReader defaultGoogleReader] signOut];
        [self updateUI];
    }
    else
    {
        UIViewController* viewController = [[PLGoogleReader defaultGoogleReader] viewControllerForSignIn:self];    
        [self.navigationController pushViewController:viewController animated:YES];        
    }
}

- (IBAction)reload:(id)sender {
    PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];    
    [[googleReader subscription] reload:self];        
}

- (IBAction)navigate:(id)sender {
    CategoryViewController *viewController = [[CategoryViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];                
}

#pragma mark PLGoogleReaderSignInDelegate
- (void)googleReaderDidSignIn:(PLGoogleReader*)googleReader 
                        error:(NSError*)error
{    
    [self.navigationController popViewControllerAnimated:YES];
    if(error)
    {
        NSLog(@"error:%@", error);        
    }        
    else
    {
        NSLog(@"sign successful");
        PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];    
        [[googleReader subscription] reload:self];            
        
        [self updateUI];
    }
}

#pragma mark PLGRSubscriptionDelegate
- (void) subscriptionDidLoad:(PLGRSubscription*)subscription
{
    NSLog(@"%@", subscription);
    [self updateUI];
}

#pragma mark PLGRRequestDelegate
- (void)request:(PLGRRequest*)request didLoad:(NSData*)result
{
    NSLog(@"request result:%@", [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease]);
}

- (void)request:(PLGRRequest*)request didFailWithError:(NSError*)error
{
    NSLog(@"request error:%@", [error localizedDescription]);    
}

@end
