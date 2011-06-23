//
//  PLGRRequest.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/11/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////////////////////////////////////
@class PLGoogleReader;
@protocol PLGRRequestDelegate;

/**
 * Don't create me directly. Please use PLGoogleReader +requestWithXXX
 */
@interface PLGRRequest : NSObject {
    id<PLGRRequestDelegate> _delegate;

    // request parameters
    PLGoogleReader*         _googleReader;    
    NSURL*                  _url;
    NSMutableDictionary*    _params;
    NSString*               _httpMethod;    
    
    // Data when connecting...
    NSURLConnection*        _urlConncetion;    
    NSMutableData*          _data;
    
    //
    BOOL                    _isCanceled;
}

@property (nonatomic, copy)     NSURL* url;
@property (nonatomic, copy)     NSMutableDictionary* params;
@property (nonatomic, copy)     NSString* httpMethod;
@property (nonatomic, retain)   PLGoogleReader* googleReader;
@property (nonatomic, assign)   id<PLGRRequestDelegate> delegate;

- (void)connect;

- (void)cancel;

- (BOOL)isLoading;

@end

///////////////////////////////////////////////////////////////////////////////////////
@protocol PLGRRequestDelegate <NSObject>
@optional
- (void)request:(PLGRRequest*)request didFailWithError:(NSError*)error;
- (void)request:(PLGRRequest*)request didLoad:(NSData*)data;
@end