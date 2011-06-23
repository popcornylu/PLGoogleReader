//
//  FeedEntry.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/17/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "FeedEntry.h"

@implementation FeedEntry
@synthesize entryid, title, link, summary, content, isRead;

- (void)dealloc
{
    [entryid release];
    [title release];
    [link release];
    [summary release];
    [content release];
    [super dealloc];
}
@end
