//
//  PLGoogleReader.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/11/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLGRRequest.h"
#import "PLGRClientLogin.h"

@class GTMOAuthAuthentication;
@class PLGRSubscription;


typedef enum
{
    PLGoogleReaderAuthTypeUnknown,
    PLGoogleReaderAuthTypeNormal,   //login by email/password
    PLGoogleReaderAuthTypeOAuth     //login by oauth
}   PLGoogleReaderAuthType;

////////////////////////////////////////////////////////////////////////////////////////////////
@protocol PLGoogleReaderSignInDelegate;
@interface PLGoogleReader : NSObject {
    PLGoogleReaderAuthType              _authType;
    
    PLGRClientLogin*                    _clientLogin;    
    GTMOAuthAuthentication*             _oauth;
    
    id<PLGoogleReaderSignInDelegate>    _delegate;
    PLGRSubscription*                   _subscription;
}

@property (nonatomic) PLGoogleReaderAuthType authType;

/**
 * The singleton google reader. 
 * Easy to use for single google reader account environment.
 */
+ (PLGoogleReader*)defaultGoogleReader;

- (UIViewController*)viewControllerForSignIn:(id<PLGoogleReaderSignInDelegate>)delegate;

- (void) signInByEmail:(NSString*)email
              password:(NSString*)password
              delegate:(id<PLGoogleReaderSignInDelegate>)delegate;

- (void) signOut;

- (BOOL) isSignedIn;

/**
 * Request data from google reader api
 */
- (PLGRRequest*)requestWithAPIPath:(NSString *)path
                        withParams:(NSMutableDictionary *)params
                    withHttpMethod:(NSString *)httpMethod
                      withDelegate:(id <PLGRRequestDelegate>)delegate;

- (PLGRRequest*)requestWithStreamContents:(NSString *)streamid
                               withParams:(NSMutableDictionary *)params
                             withDelegate:(id <PLGRRequestDelegate>)delegate;

- (PLGRRequest*)requestWithAtomPath:(NSString *)path
                         withParams:(NSMutableDictionary *)params
                       withDelegate:(id <PLGRRequestDelegate>)delegate;



/**
 * Authorize the request. This method would add OAUTH params to querystring or httpheader.
 * The API allow user to request google reader api by raw NSURLConnection
 */
- (BOOL)authorizeRequest:(NSMutableURLRequest*)urlRequest;

/**
 * Get the subscription object.
 */
- (PLGRSubscription*)subscription;

/**
 * oauth relative
 */
- (NSString*) accessToken;
- (NSString*) userEmail;
- (GTMOAuthAuthentication*)oauth;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
@protocol PLGoogleReaderSignInDelegate <NSObject>
@optional
/**
 * Called when sign-in is completed.
 * If error is error, the singin is successful; Otherwise, it is failed.
 */
- (void)googleReaderDidSignIn:(PLGoogleReader*)googleReader 
                        error:(NSError*)error;

@end
