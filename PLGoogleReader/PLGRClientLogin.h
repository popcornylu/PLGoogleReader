//
//  PLGRClientLogin.h
//  PLGoogleReader
//
//  Created by Popcorny on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PLGRCompleteBlock)(NSError*);

@interface PLGRClientLogin : NSObject {
    NSString        *_email;
    NSURLConnection *_connection;
    NSMutableData   *_data;
    NSString        *_auth;
    
    //    
    PLGRCompleteBlock   _completeBlock;
}


@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* auth;
@property (nonatomic, copy) PLGRCompleteBlock completeBlock;


- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
              complete:(void(^)(NSError*))complete;

- (void)logout;

- (BOOL)authorizeRequest:(NSMutableURLRequest *)request;

@end
