//
//  PLGRSubscription.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/13/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "PLGRSubscription.h"
#import "PLGRSubscriptionItem.h"

#import "JSON.h"

static NSString* kPLGRAPISubscriptionList   =  @"/subscription/list";
static NSString* kPLGRAPITagList            =  @"/tag/list";
static NSString* kPLGRAPIPrefStreamList     =  @"/preference/stream/list";
static NSString* kPLGRAPIUnreadCount        =  @"/unread-count";
static NSString* kPLGRAPIToken              =  @"/token";


@interface NSString (PLGRSubscription)
- (NSString*)normalizedStreamId;
@end

@implementation PLGRSubscription

@synthesize delegate = _delegate;

/**
 * Please use [PLGoogleReader subscription] instead.
 */
- (id)initWithReader:(PLGoogleReader*)gooleReader
{
    self = [super init];
    
    if(self)        
    {
        // we don't retain it.
        _googleReader = gooleReader;
    }
    
    return self;
}

- (void)dealloc
{         
    if([self isLoading])
    {
        [self cancel];
    }
    
    [_lastUpdated release];
    [_arSubscriptions release];
    [_arTags release];
    [_arStreamPrefs release];
    [_arUnreadCount release];

    [super dealloc];
}

#pragma mark PLGRRequestDelegate
- (void)handleSubscriptionListRequest:(id)resultData
{
    NSMutableArray* items = [NSMutableArray array];
    
    id resultSubscriptions = [resultData objectForKey:@"subscriptions"];    
    if(resultSubscriptions && [resultSubscriptions isKindOfClass:[NSArray class]])
    {
        for (id resultItem in resultSubscriptions) 
        {
            PLGRSubscriptionItem* item = [[PLGRSubscriptionItem alloc] init];            
            
            // item data
            item.streamid = [resultItem objectForKey:@"id"];
            item.sortid = [resultItem objectForKey:@"sortid"];
            item.title  = [resultItem objectForKey:@"title"];
            NSString* firstTimeSec = [resultItem objectForKey:@"firstitemmsec"];                                    
            item.firstItemSec = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[firstTimeSec doubleValue] / 1000];
            
            // Categories
            id resultCategories = [resultItem objectForKey:@"categories"];
            if(resultCategories && [resultCategories isKindOfClass:[NSArray class]])
            {
                NSMutableArray* categories = [NSMutableArray arrayWithCapacity:0];                
                for(id resultCategory in resultCategories)
                {
                    [categories addObject:[(NSString*)[resultCategory objectForKey:@"id"] normalizedStreamId]];
                }
                item.labels = categories;
            }           
            
            [items addObject:item];            
            [item release];           
        }
    }
    
    // Keep the result
    [_arSubscriptions release];
    _arSubscriptions = [items retain];
}

- (void)handleTagListRequest:(id)resultData
{
    NSMutableArray* items = [NSMutableArray array];        
    id resultTags = [resultData objectForKey:@"tags"];
    
    if(resultTags && [resultTags isKindOfClass:[NSArray class]])
    {
        for (id resultTag in resultTags) 
        {
            PLGRSubscriptionItem* item = [[PLGRSubscriptionItem alloc] init];            
            
            // item data
            item.streamid = [(NSString*)[resultTag objectForKey:@"id"] normalizedStreamId];
            item.sortid = [resultTag objectForKey:@"sortid"];                        
            
            // Diffferent type of tag
            NSArray* components = [item.streamid componentsSeparatedByString:@"/"];
            if([components count] == 4 && 
               [(NSString*)[components objectAtIndex:2] isEqualToString:@"label"])
            {                
                //  user/1234567890/label/some-label-string
                
                item.title = [components objectAtIndex:3];
            }
            else if([components count] == 5)
            {
                if([(NSString*)[components objectAtIndex:4] isEqualToString:@"starred"])
                {
                    item.title = NSLocalizedString(@"Starred", nil);                
                }
                else if([(NSString*)[components objectAtIndex:4] isEqualToString:@"broadcast"])
                {
                    item.title = NSLocalizedString(@"Broadcast", nil);                                    
                }                
                else if([(NSString*)[components objectAtIndex:4] isEqualToString:@"blogger-following"])                
                {
                    item.title = NSLocalizedString(@"Blogger following", nil);                                    
                }                
                else
                {
                    item.title = NSLocalizedString(@"Unknown", nil);                    
                }
            }
            else
            {
                item.title = NSLocalizedString(@"Unknown", nil);                                    
            }
                    
            //
            [items addObject:item];            
            [item release];            
        }
    }    
    
    // Keep the result
    [_arTags release];
    _arTags = [items retain];    
}

- (void)handleSortingListRequest:(id)resultData
{
    NSMutableArray* items = [NSMutableArray array];        
    id resultStreamPrefs = [resultData objectForKey:@"streamprefs"];
    
    if(resultStreamPrefs && [resultStreamPrefs isKindOfClass:[NSDictionary class]])
    {
        for (id resultStreamId in [(NSDictionary*)resultStreamPrefs keyEnumerator]) 
        {
            PLGRStreamPref* item = [[PLGRStreamPref alloc] init];            
            id resultStreamAttrs = [(NSDictionary*)resultStreamPrefs objectForKey:resultStreamId];
            
            // item data
            item.streamid = [(NSString*)resultStreamId normalizedStreamId];
            
            for(NSDictionary* resultStreamAttr in resultStreamAttrs)
            {
                NSString* resultStreamAttrId = [resultStreamAttr objectForKey:@"id"];
                id resultStreamAttrValue     = [resultStreamAttr objectForKey:@"value"];
                
                if([resultStreamAttrId isEqualToString:@"is-expanded"])
                {
                    item.isExpended = [(NSString*)resultStreamAttrValue boolValue];
                }
                else if([resultStreamAttrId isEqualToString:@"subscription-ordering"])
                {
                    item.subscriptionOrdering  = resultStreamAttrValue;
                }
            }      
            
            [items addObject:item];            
            [item release];            
        }
    }   
    
    // Keep the result
    [_arStreamPrefs release];
    _arStreamPrefs = [items retain];        
}

- (void)handleUnreadCountRequest:(id)resultData
{
    NSMutableArray* items = [NSMutableArray array];        
    id resultUnreadCounts = [resultData objectForKey:@"unreadcounts"];
    
    if(resultUnreadCounts && [resultUnreadCounts isKindOfClass:[NSArray class]])
    {
        for (id resultUnreadCount in resultUnreadCounts) 
        {
            PLGRUnreadCount* item = [[PLGRUnreadCount alloc] init];                        
            // item data
            item.streamid = [(NSString*)[resultUnreadCount objectForKey:@"id"] normalizedStreamId];
            item.count  = (NSUInteger)[[resultUnreadCount objectForKey:@"count"] longLongValue];            
            NSString* newestItemTimestampUsec = [resultUnreadCount objectForKey:@"newestItemTimestampUsec"];                                    
            item.newestItemTimestampUsec = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[newestItemTimestampUsec doubleValue] / 1000000];                        
            [items addObject:item];            
            [item release];            
        }
    }   
    
    // Keep the result
    [_arUnreadCount release];
    _arUnreadCount = [items retain];        
}


- (void)checkReloadComplete
{
    if(!_requestSubscription && !_requestTag && !_requestSorting && !_requestUnreadCount)
    {
        // Set last updated to now.
        [_lastUpdated release];
        _lastUpdated = [[NSDate alloc] init];
        
        //complete
        [_delegate subscriptionDidLoad:self];
    }
}

- (void)request:(PLGRRequest*)request didLoad:(NSData*)data
{
    NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];    
    id resultData = [result JSONValue];
    
    if(_requestSubscription == request)
    {        
        [self handleSubscriptionListRequest:resultData];    
        [_requestSubscription release];
        _requestSubscription = nil;            
    }
    else if(_requestTag == request)
    {
        [self handleTagListRequest:resultData];    
        [_requestTag release];
        _requestTag = nil;            
    }
    else if(_requestSorting == request)
    {
        [self handleSortingListRequest:resultData];    
        [_requestSorting release];
        _requestSorting = nil;                    
    }
    else if(_requestUnreadCount == request)
    {
        [self handleUnreadCountRequest:resultData];
        [_requestUnreadCount release];
        _requestUnreadCount = nil;
    }
    
    [result release];
    [self checkReloadComplete];
}

- (void)request:(PLGRRequest*)request didFailWithError:(NSError*)error
{
    if(_requestSubscription == request)
    {
        [_requestSubscription release];
        _requestSubscription = nil;    
    }
    else if(_requestTag == request)
    {
        [_requestTag release];
        _requestTag = nil;            
    }
    else if(_requestSorting == request)
    {
        [_requestSorting release];
        _requestSorting = nil;                    
    }
    else if(_requestUnreadCount == request)
    {
        [_requestUnreadCount release];
        _requestUnreadCount = nil;
    }
    [self checkReloadComplete];    
}



#pragma mark Public
- (BOOL) isLoaded
{
    // Check if all the list is loaded.
    return (_arSubscriptions &&
            _arTags &&
            _arStreamPrefs &&
            _arUnreadCount);
}

- (BOOL) isLoading
{
    // Check if one of request is still running
    return (_requestSubscription ||
            _requestTag ||
            _requestSorting ||
            _requestUnreadCount);    
}

- (void) cancel
{    
    // Cancel all the requests
    if(_requestSubscription)
    {
        [_requestSubscription cancel];
        [_requestSubscription release];
        _requestSorting = nil;
    }
    
    if(_requestTag)
    {
        [_requestTag cancel];        
        [_requestTag release];
        _requestTag = nil;        
    }
    
    if(_requestSorting)
    {
        [_requestSorting cancel];
        [_requestSorting release];
        _requestSorting = nil;        
    }
    
    if(_requestUnreadCount)
    {
        [_requestUnreadCount cancel];
        [_requestUnreadCount release];
        _requestUnreadCount = nil;
    }
}

- (void) reset
{
    [_arSubscriptions release];
    _arSubscriptions = nil;         
    [_arTags release];
    _arTags = nil;     
    [_arStreamPrefs release];
    _arStreamPrefs = nil;  
    [_arUnreadCount release];
    _arUnreadCount = nil;

    [_lastUpdated release];
    _lastUpdated = nil;
}

- (void) reload:(id<PLGRSubscriptionDelegate>)delegate
{
    _delegate = delegate;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"json", @"output",
                                   nil];
    
    //
    _requestSubscription = [_googleReader requestWithAPIPath:kPLGRAPISubscriptionList 
                                                  withParams:params
                                              withHttpMethod:nil 
                                                withDelegate:self];
    [_requestSubscription retain];
    
    //
    _requestTag = [_googleReader requestWithAPIPath:kPLGRAPITagList
                                         withParams:params
                                     withHttpMethod:nil 
                                       withDelegate:self];
    [_requestTag retain];  
    
    //
    _requestSorting = [_googleReader requestWithAPIPath:kPLGRAPIPrefStreamList
                                             withParams:params
                                         withHttpMethod:nil 
                                           withDelegate:self];
    [_requestSorting retain];
    
    //
    _requestUnreadCount = [_googleReader requestWithAPIPath:kPLGRAPIUnreadCount
                                                 withParams:params
                                             withHttpMethod:nil 
                                               withDelegate:self];
    [_requestUnreadCount retain];    
    
    [_googleReader requestWithAPIPath:kPLGRAPIToken
                           withParams:params
                       withHttpMethod:nil 
                         withDelegate:nil];
}

- (NSDate*) lastUpdated
{
    return _lastUpdated;
}

- (NSArray*) subscriptionList
{
    return [[_arSubscriptions copy] autorelease];
}

- (NSArray*) tagList
{
    return [[_arTags copy] autorelease];
}

- (NSArray*) sortedListForTagOld:(NSString*)streamid
{
    PLGRStreamPref* streamPref = nil;
    NSUInteger itemCount = 0;
    NSMutableArray* sortedList = [NSMutableArray array];
    
    if(streamid == nil)
    {
        streamid = @"user/-/state/com.google/root";
    }
    
    // iterate the sorting
    for (streamPref in _arStreamPrefs) {
        if([streamPref.streamid isEqualToString:streamid])
        {
            break;
        }
    }
    
    // check if the stream id is found.
    if(streamPref != nil)
    {    
        //
        itemCount = [streamPref.subscriptionOrdering length] / 8;
        for(NSUInteger i=0; i<itemCount; i++)
        {
            PLGRSubscriptionItem* subItem = nil;
            NSString* subItemSortid = [streamPref.subscriptionOrdering substringWithRange:NSMakeRange(8*i, 8)];
            
            // Find the item from subscriptions
            for(subItem in _arSubscriptions)
            {
                if([subItem.sortid isEqualToString:subItemSortid])
                {
                    break;
                }
            }        
            if(subItem != nil)
            {
                [sortedList addObject:subItem];
                continue;
            }
            
            // Find the item from tags
            for(subItem in _arTags)
            {
                if([subItem.sortid isEqualToString:subItemSortid])
                {
                    break;
                }
            }        
            if(subItem != nil)
            {
                [sortedList addObject:subItem];
                continue;
            }
            
            // Not found      
        }
    }
    
    // Recheck all the itmes in subscription. 
    // Gurantee all the item with the speicified category are put in the 
    // sorted list.
    for(PLGRSubscriptionItem* subItem in _arSubscriptions)
    {
        NSString* categoryStreamid = nil;
        for(categoryStreamid in subItem.labels)
        {
            if([categoryStreamid isEqualToString:streamid])
            {
                if(![sortedList containsObject:subItem])
                {
                    [sortedList addObject:subItem];
                }
            }
        }
    }
    
    return sortedList;
}

- (NSArray*) listForRoot
{
    NSMutableSet* tagSet = [NSMutableSet set];
    NSMutableArray* feedList = [NSMutableArray arrayWithCapacity:0];    
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:0];
    
    
    // iterate the subscription to get the root items and root tags
    for(PLGRSubscriptionItem* item in _arSubscriptions)
    {
        if([item.labels count] == 0)
        {
            [feedList addObject:item];
        }
        else
        {
            for(NSString* tag in item.labels)
            {
                if(![tagSet containsObject:tag])
                {
                    [tagSet addObject:tag];
                }
            }
        }        
    }    
    
    // Append the tags.
    for(PLGRSubscriptionItem* tagItem in _arTags)
    {
        if([tagSet containsObject:tagItem.streamid])
        {
            [list addObject:tagItem];           
        }
    }
    
    // Append the feed list at the tail.
    [list addObjectsFromArray:feedList];
    
    return [NSArray arrayWithArray:list];                    
}

- (NSArray*) listForTag:(NSString*)streamid
{
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:0];
    
    // iterate the subscription to get the items which belong to the streamid
    for(PLGRSubscriptionItem* item in _arSubscriptions)
    {
        for(NSString* tag in item.labels)
        {
            if([tag isEqualToString:streamid])
            {
                [list addObject:item];
            }
        }
    }    
    
    return [NSArray arrayWithArray:list]; 
}

- (NSArray*) sortedListForTag:(NSString*)streamid
{   
    NSArray* list = (streamid == nil) ? 
                    [self listForRoot] : 
                    [self listForTag:streamid];
    
    PLGRStreamPref* streamPref = nil;
    NSUInteger itemCount = 0;
    
    NSMutableArray* sortedList = [NSMutableArray array];
    NSMutableArray* tempList   = [NSMutableArray arrayWithArray:list];
    
    if(streamid == nil)
    {
        streamid = @"user/-/state/com.google/root";
    }
    
    // iterate the sorting
    for (streamPref in _arStreamPrefs) {
        if([streamPref.streamid isEqualToString:streamid])
        {
            break;
        }
    }
    
    // check if the stream preference is found.
    if(streamPref != nil)
    {    
        itemCount = [streamPref.subscriptionOrdering length] / 8;
        for(NSUInteger i=0; i<itemCount; i++)
        {
            NSString* subItemSortid = [streamPref.subscriptionOrdering substringWithRange:NSMakeRange(8*i, 8)];
            
            // Find the item from list
            for(PLGRSubscriptionItem* subItem in list)
            {
                // If found, add it to the sorted list
                if([subItem.sortid isEqualToString:subItemSortid])
                {
                    [sortedList addObject:subItem];
                    [tempList  removeObject:subItem];
                }
            }        
        }
    }
    
    [sortedList addObjectsFromArray:tempList];
    
    return [NSArray arrayWithArray:sortedList];
}

- (NSUInteger) unreadCountForTag:(NSString*)streamid
{
    PLGRUnreadCount* unreadCount = nil;
    
    if(streamid == nil)
    {
        streamid = @"user/-/state/com.google/reading-list";
    }
    
    for (unreadCount in _arUnreadCount) {
        if([unreadCount.streamid isEqualToString:streamid])
        {
            break;
        }
    }
    
    // check if the stream id is found.
    if(unreadCount != nil)
    {    
        return unreadCount.count;
    }
    else
    {    
        return 0;    
    }
}

#pragma mark Description
- (void)recursiveDescritpion:(PLGRSubscriptionItem*)item 
                  withIndent:(NSString*)indent
                    toBuffer:(NSMutableString*)buffer
{    
    NSArray* sortedList = [self sortedListForTag:item ? item.streamid : nil];
    
    for (PLGRSubscriptionItem* subItem in sortedList) {
        [buffer appendFormat:@"%@[%@]\t%@\n", indent, subItem.title, subItem.streamid];
        if(![subItem.streamid hasPrefix:@"feed"])
        {
            [self recursiveDescritpion:subItem 
                            withIndent:[indent stringByAppendingString:@"    "] 
                              toBuffer:buffer];
        }
    }
}

- (NSString*)description
{
    NSMutableString* buffer = [NSMutableString string];
    
    [self recursiveDescritpion:nil 
                    withIndent:@""
                      toBuffer:buffer];
    
    return buffer;
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
@implementation PLGRStreamPref
@synthesize streamid, isExpended, subscriptionOrdering;

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@(isExpened=%d, ordering=%@)",
                                      self.streamid,
                                      self.isExpended,
                                      self.subscriptionOrdering];
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////
@implementation PLGRUnreadCount
@synthesize streamid, count, newestItemTimestampUsec;

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@(count=%d, newestItemTimestampUsec=%@)",
            self.streamid,
            self.count,
            self.newestItemTimestampUsec];
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (PLGRSubscription)
/**
 * Replace 
 * "user/1234567890/state/com.google/xxx"
 * to 
 * "user/-/state/com.google/xxx"
 *
 */
- (NSString*)normalizedStreamId
{    
    if([self hasPrefix:@"user/"])
    {
        NSArray* comps = [self componentsSeparatedByString:@"/"];
        NSMutableArray* newComps = [[comps mutableCopy] autorelease];
        [newComps replaceObjectAtIndex:1 withObject:@"-"];
        return [newComps componentsJoinedByString:@"/"];
    }
    else
    {
        return self;
    }
}
@end