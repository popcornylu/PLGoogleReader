//
//  FeedEntry.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/17/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FeedEntry : NSObject {
@private
    NSString* entryid;    
    NSString* title;
    NSString* link;
    NSString* summary;
    NSString* content;
    BOOL      isRead;
}

@property (nonatomic, copy) NSString* entryid;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* link;
@property (nonatomic, copy) NSString* summary;
@property (nonatomic, copy) NSString* content;
@property (nonatomic) BOOL isRead;

@end
