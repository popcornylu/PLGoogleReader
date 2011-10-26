//
//  PLGoogleReader.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/11/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "PLGoogleReader.h"

#import "PLGRSubscription.h"

// oauth implementation by GTM (google toolbox for mac)
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

static PLGoogleReader* gDefaultGoogleReader = nil;

// Scopes for google service.
// static NSString* const kPLGRScope       = @"http://www.google.com/reader/api http://www.google.com/reader/atom";
static NSString* const kPLGRScope       = @"http://www.google.com/reader/api";

// API root
static NSString* const kPLGRAPIPrefix   = @"http://www.google.com/reader/api/0";
static NSString* const kPLGRAtomPrefix  = @"http://www.google.com/reader/atom";
static NSString* const kPLGRStreamContentsPrefix  = @"http://www.google.com/reader/api/0/stream/contents";

// Used for keychain service name
static NSString* const kPLGRAppName     = @"Google Reader";

@interface PLGoogleReader ()
@property (retain) GTMOAuthAuthentication* oauth;
@property (retain) PLGRClientLogin* clientLogin;
@end

@implementation PLGoogleReader

@synthesize authType = _authType;
@synthesize oauth = _oauth;
@synthesize clientLogin = _clientLogin;

#pragma mark NSObject
- (id)init
{
    self = [super init];
    if(self)        
    {
        self.clientLogin = [[[PLGRClientLogin alloc] init] autorelease];
        self.oauth       = [GTMOAuthViewControllerTouch authForGoogleFromKeychainForName:kPLGRAppName];                                
    }    
    return self;
}

- (void)dealloc
{
    self.oauth = nil;
    self.clientLogin = nil;
    
    [super dealloc];
}


#pragma mark Public
- (UIViewController*)viewControllerForSignIn:(id<PLGoogleReaderSignInDelegate>)delegate
{    
    // Only allow the delegate is not nil
    if(delegate == nil)
    {
        return nil;
    }
    
    // Don't allow concurrent login.
    if(_delegate != nil)
    {
        return nil;
    }
    
    _delegate = delegate;
    _authType = PLGoogleReaderAuthTypeOAuth;
    
    // Create the sign in view controller by GTM
    GTMOAuthViewControllerTouch *viewController = 
        [[[GTMOAuthViewControllerTouch alloc]
                initWithScope:kPLGRScope
                     language:nil
               appServiceName:kPLGRAppName
                     delegate:self
             finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];    
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    [viewController setInitialHTMLString:html];
    

    
    //
    return viewController;
}

- (void) signInByEmail:(NSString*)email
              password:(NSString*)password
              delegate:(id<PLGoogleReaderSignInDelegate>)delegate
{    
    _authType = PLGoogleReaderAuthTypeNormal;    
    [self.clientLogin loginWithEmail:email 
                            password:password 
                            complete:^(NSError *error) 
    {
        [delegate googleReaderDidSignIn:self error:error];
    }];
}

- (BOOL) isSignedIn
{
    if(self.authType == PLGoogleReaderAuthTypeNormal)
    {
        return [self.clientLogin auth] != nil;
    }
    else if(self.authType == PLGoogleReaderAuthTypeOAuth)
    {
        return [self.oauth canAuthorize];
    }
    else
    {
        if([self.oauth canAuthorize])
        {
            _authType = PLGoogleReaderAuthTypeOAuth;
            return YES;            
        }
        else
        {
            return NO;
        }
    }    
}

- (void) signOut
{
    if(self.authType == PLGoogleReaderAuthTypeNormal)    
    {
        [self.clientLogin logout];
    }
    else if(self.authType == PLGoogleReaderAuthTypeOAuth)
    {
        // Revoke access token from google auth service
        [GTMOAuthViewControllerTouch revokeTokenForGoogleAuthentication:self.oauth];
        
        // Remove the access token from keychain
        [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kPLGRAppName];
        
        // Reset the authentication object
        [self.oauth reset];
    }
    
    //subscription
    if([_subscription isLoading])
    {
        [_subscription cancel];
    }
    [_subscription reset];
}


/**
 * Create a googler reader API request. 
 * 
 * if the api is http://www.google.com/reader/api/0/subscription/list 
 * the path should be "/subscription/list"
 *
 */
- (PLGRRequest*)requestWithAPIPath:(NSString *)path
                        withParams:(NSMutableDictionary *)params
                    withHttpMethod:(NSString *)httpMethod
                      withDelegate:(id <PLGRRequestDelegate>)delegate
{
    NSString* fullpath = [path hasPrefix:@"/"] ?
                         [kPLGRAPIPrefix stringByAppendingString:path] :
                         [kPLGRAPIPrefix stringByAppendingFormat:@"/%@", path];
    
    NSURL* url = [NSURL URLWithString:fullpath];    
   
    PLGRRequest* request = [[[PLGRRequest alloc] init] autorelease];
    request.googleReader = self;
    request.url = url;
    request.params = params;
    request.httpMethod = httpMethod;
    request.delegate = delegate;    
    
    [request connect];
    
    return request;
}

/**
 * Get the stream contents for a given stream id.
 *
 * Note: I don't know why this api can't work for stream with /user/xxxxx. 
 * and just got the HTTP code 401: Unautherized
 */
- (PLGRRequest*)requestWithStreamContents:(NSString *)streamid
                               withParams:(NSMutableDictionary *)params
                             withDelegate:(id <PLGRRequestDelegate>)delegate
{
    //escape the special character in path
    NSString* escapedStreamid = (NSString *)
        CFURLCreateStringByAddingPercentEscapes(NULL, /* allocator */
                                                (CFStringRef)streamid,
                                                NULL, /* charactersToLeaveUnescaped */
                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                kCFStringEncodingUTF8);                       
    NSString* fullpath = [kPLGRStreamContentsPrefix stringByAppendingFormat:@"/%@", escapedStreamid];    
    NSURL* url = [NSURL URLWithString:fullpath];    
    [escapedStreamid release];                
    
    // Create the google reader request.
    PLGRRequest* request = [[[PLGRRequest alloc] init] autorelease];
    request.googleReader = self;
    request.url = url;
    request.params = params;
    request.delegate = delegate;    
    
    [request connect];            
    return request;    
}

/**
 * Create a googler reader ATOM request. 
 * 
 * For the path, if the api is http://www.google.com/reader/atom/feed/http://my.feed.path
 * the path should be '/feed/http://my.feed.path'
 *
 * Note: Pleas add "http://www.google.com/reader/atom" to kPLGRScope. Otherwise, this message may not work.
 */
- (PLGRRequest*)requestWithAtomPath:(NSString *)path
                         withParams:(NSMutableDictionary *)params
                       withDelegate:(id <PLGRRequestDelegate>)delegate
{    
    //escape the special character in path
    NSString* escapedPath = (NSString *)
        CFURLCreateStringByAddingPercentEscapes(NULL, /* allocator */
                                                (CFStringRef)path,
                                                NULL, /* charactersToLeaveUnescaped */
                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                kCFStringEncodingUTF8);                       
    NSString* fullpath = [path hasPrefix:@"/"] ?
                         [kPLGRAtomPrefix stringByAppendingString:escapedPath] :
                         [kPLGRAtomPrefix stringByAppendingFormat:@"/%@", escapedPath];   
    
    NSURL* url = [NSURL URLWithString:fullpath];    
    [escapedPath release];            
    
    
    // Create the google reader request.
    PLGRRequest* request = [[[PLGRRequest alloc] init] autorelease];
    request.googleReader = self;
    request.url = url;
    request.params = params;
    request.delegate = delegate;    
    
    [request connect];
        
    return request;
}

#pragma mark signin callback
- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error 
{    
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"Signin failed: %@", str);
        }       
        [self.oauth reset];
    } 
    else
    {
        self.oauth = auth;
    }
    
    // Notify to delegate
    if(_delegate)
    {
        [_delegate googleReaderDidSignIn:self error:error];
    }
    
    // unset the delegate
    _delegate = nil;
}

/**
 * Authorize the request. This method would add OAUTH params to querystring or httpheader.
 */
- (BOOL) authorizeRequest:(NSMutableURLRequest*)urlRequest
{
    if(self.authType == PLGoogleReaderAuthTypeNormal)
    {
        if(![_clientLogin auth])
        {
            return NO;
        }
        
        return [_clientLogin authorizeRequest:urlRequest];
    }
    else if(self.authType == PLGoogleReaderAuthTypeOAuth)
    {
        if(![_oauth canAuthorize])
        {
            return NO;
        }
        
        return [_oauth authorizeRequest:urlRequest];
    }
    else
    {
        return NO;
    }
}

/**
 * Return the singleton subscription for current google reader object.
 */
- (PLGRSubscription*)subscription
{
    if(_subscription == nil)
    {
        _subscription = [[PLGRSubscription alloc] initWithReader:self];
    }
    
    return _subscription;
}

- (NSString*) accessToken
{
    if(self.authType == PLGoogleReaderAuthTypeNormal)
    {
        return [_clientLogin auth];
    }
    else if(self.authType == PLGoogleReaderAuthTypeOAuth)
    {
        return [_oauth accessToken];
    }
    else
    {
        return nil;
    }
}

- (NSString*) userEmail
{
    if(self.authType == PLGoogleReaderAuthTypeNormal)
    {
        return [_clientLogin email];
    }
    else if(self.authType == PLGoogleReaderAuthTypeOAuth)
    {
        return [_oauth userEmail];
    }
    else
    {
        return nil;
    }
}

#pragma mark Class Public
+ (PLGoogleReader*)defaultGoogleReader
{
    if(gDefaultGoogleReader == nil)
    {
        gDefaultGoogleReader = [[PLGoogleReader alloc] init]; 
    }
    
    return gDefaultGoogleReader;
}

@end
