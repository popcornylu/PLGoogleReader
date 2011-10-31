//
//  PLGRSubscription.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/13/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "PLGoogleReader.h"
#import "PLGRRequest.h"


@protocol PLGRSubscriptionDelegate;
@class PLGRSubscriptionItem;

/**
 * This is a utility class to load the following API
 * http://www.google.com/reader/api/0/subscription/list
 * http://www.google.com/reader/api/0/tag/list
 * http://www.google.com/reader/api/0/preference/stream/list
 * http://www.google.com/reader/api/0/unread-count
 */
@interface PLGRSubscription : NSObject <PLGRRequestDelegate>{
    PLGoogleReader* _googleReader;
    
    //
    NSDate* _lastUpdated;    
    
    //lists
    NSArray* _arSubscriptions;
    NSArray* _arTags;
    NSArray* _arStreamPrefs;
    NSArray* _arUnreadCount;    
    
    //data for loading
    id<PLGRSubscriptionDelegate> _delegate;    
    PLGRRequest* _requestSubscription;
    PLGRRequest* _requestTag;  
    PLGRRequest* _requestSorting;       
    PLGRRequest* _requestUnreadCount;
}

@property (nonatomic, assign) id<PLGRSubscriptionDelegate> delegate;

/**
 * Please use [PLGoogleReader subscription] instead.
 */
- (id)initWithReader:(PLGoogleReader*)gooleReader;

/**
 * If the subscription is loading
 */
- (BOOL) isLoaded;

/**
 * If the subscription is loaded
 */
- (BOOL) isLoading;

/**
 * If the operation canceled.
 */
- (void) cancel;

/**
 * Reset the subscription. Used for the google reader is signed out.
 */
- (void) reset;

/**
 * Reload the subscription list.
 */
- (void) reload:(id<PLGRSubscriptionDelegate>)delegate;

/**
 * Retrieve the last update time
 */
- (NSDate*) lastUpdated;
 
/**
 * Return all the individual feed.
 * This api is corresponding to the result of 
 * http://www.google.com/reader/api/0/subscription/list
 */
- (NSArray*) subscriptionList;


/**
 * Return all the tags.
 * This api is corresponding to the result of 
 * http://www.google.com/reader/api/0/tag/list
 */
- (NSArray*) tagList;

/**
 * Return the sorted items according to the streamid
 * If the streamid is not specified. The root list is return
 * 
 * @return 
 *      an array of the PLGRSubscriptionItem. If no streamid match, return an empty array.
 */
- (NSArray*) sortedListForTag:(NSString*)streamid;


/**
 * Return the unread count for tag
 * 
 * @return 
 *      unread count
 */
- (NSUInteger) unreadCountForTag:(NSString*)streamid;


@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@protocol PLGRSubscriptionDelegate <NSObject>
- (void) subscriptionDidLoad:(PLGRSubscription*)subscription;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface PLGRStreamPref : NSObject {
    NSString*   streamid;
    BOOL        isExpended;
    NSString*   subscriptionOrdering;
}

@property (nonatomic, copy) NSString* streamid;
@property (nonatomic) BOOL isExpended;
@property (nonatomic, copy) NSString* subscriptionOrdering;
@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface PLGRUnreadCount : NSObject {
    NSString*   streamid;
    NSUInteger  count;
    NSDate*     newestItemTimestampUsec;
}

@property (nonatomic, copy) NSString* streamid;
@property (nonatomic) NSUInteger  count;
@property (nonatomic, copy) NSDate*     newestItemTimestampUsec;
@end