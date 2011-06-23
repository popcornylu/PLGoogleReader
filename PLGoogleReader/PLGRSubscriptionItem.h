//
//  PLGRSubscriptionAtom.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/13/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLGRSubscriptionItem : NSObject {
    NSString*       streamid;
    NSString*       title;
    NSString*       sortid;
    
    // If the atom is a individual atom feed, we have following additional data
    NSMutableArray* labels;           // Contain the id of the tags
    NSDate*         firstItemSec;
}

@property (nonatomic, copy) NSString* streamid;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* sortid;
@property (nonatomic, retain) NSMutableArray* labels;
@property (nonatomic, copy) NSDate* firstItemSec;

- (BOOL) isIndividualFeed;

- (BOOL) isLabel;

+ (PLGRSubscriptionItem*)itemWithStreamId:(NSString*)streamid
                                 andTitle:(NSString*)title;

@end
