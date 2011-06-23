//
//  PLGoogleReader.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/11/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLGRRequest.h"

@class GTMOAuthAuthentication;
@class PLGRSubscription;


////////////////////////////////////////////////////////////////////////////////////////////////
@protocol PLGoogleReaderSignInDelegate;
@interface PLGoogleReader : NSObject {
    GTMOAuthAuthentication*             _auth;
    id<PLGoogleReaderSignInDelegate>    _delegate;
    PLGRSubscription*                   _subscription;
}

/**
 * The singleton google reader. 
 * Easy to use for single google reader account environment.
 */
+ (PLGoogleReader*)defaultGoogleReader;

- (UIViewController*)viewControllerForSignIn:(id<PLGoogleReaderSignInDelegate>)delegate;

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
 * Authentication relative
 */
- (NSString*) accessToken;
- (NSString*) userEmail;
- (GTMOAuthAuthentication*)auth;

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
