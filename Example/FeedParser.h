//
//  ATOMParser.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/14/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedEntry;

/**
 * Deprecated class.
 * This class is designed for prasing ATOM. Please parse JSON format instead.
 */
@interface FeedParser : NSObject <NSXMLParserDelegate>
{
    NSData* _xmlData;
    NSMutableArray* _entries;
    FeedEntry* _currentEntry;
    NSString* _currentPath;
    NSMutableString* _currentText;
}

-(id)initWithXMLData:(NSData*)xmlData;
-(NSMutableArray*)parse;
@end



