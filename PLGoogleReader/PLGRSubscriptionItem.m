//
//  PLGRSubscriptionAtom.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/13/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "PLGRSubscriptionItem.h"

@implementation PLGRSubscriptionItem

@synthesize streamid;
@synthesize title;
@synthesize sortid;
@synthesize labels;
@synthesize firstItemSec;

- (NSString*)description
{
    NSMutableString* string = [NSMutableString string]; 
    
    [string appendFormat:@"%@[%@]", title, streamid];
    
    if(self.labels)
    {
        [string appendString:@"-("];
        for(NSString* labelPath in self.labels)
        {
            [string appendFormat:@"%@ ", [labelPath lastPathComponent]];
        }
        [string appendString:@")"];
    }      
    
    return string;
}

- (BOOL) isIndividualFeed
{
    return [streamid hasPrefix:@"feed/"];
}

- (BOOL) isLabel
{
    return [streamid rangeOfString:@"/label/"].location != NSNotFound;
}

+ (PLGRSubscriptionItem*)itemWithStreamId:(NSString*)streamid
                                 andTitle:(NSString*)title
{
    PLGRSubscriptionItem* item = [[[PLGRSubscriptionItem alloc] init] autorelease];
    item.streamid = streamid;
    item.title  = title;
    return item;
}

@end

