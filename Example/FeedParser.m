//
//  FeedParser.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/14/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "FeedParser.h"
#import "FeedEntry.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface FeedParser ()
@property (nonatomic, retain) FeedEntry *currentEntry;
@property (nonatomic, retain) NSString *currentPath;
@property (nonatomic, retain) NSMutableString *currentText;
@end

@implementation FeedParser 
@synthesize currentEntry = _currentEntry;
@synthesize currentPath = _currentPath;
@synthesize currentText = _currentText;

-(id)initWithXMLData:(NSData*)xmlData;
{
    self = [super init];
    if(self)
    {
        _xmlData = [xmlData retain];
    }
    return self;
}

- (void)dealloc
{
    [_xmlData release];
    [super dealloc];
}


#pragma mark NSXMLParserDelegate
// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.currentPath = @"/";
    self.currentText = [NSMutableString string];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.currentPath = nil;
    self.currentText = nil;    
}

// DTD handling methods for various declarations.
- (void)    parser:(NSXMLParser *)parser 
   didStartElement:(NSString *)elementName 
      namespaceURI:(NSString *)namespaceURI 
     qualifiedName:(NSString *)qName 
        attributes:(NSDictionary *)attributeDict
{   
    // Append the xml path
    self.currentPath = [self.currentPath stringByAppendingPathComponent:qName];        
    
    NSLog(@"path:%@", self.currentPath);
    
    // reset the text
    [self.currentText setString:@""];
    
    // Do something according to the path
    if([self.currentPath isEqualToString:@"/feed/entry"])
    {
        self.currentEntry = [[[FeedEntry alloc] init] autorelease];
    }
    else if([self.currentPath isEqualToString:@"/feed/entry/link"])
    {
        id href = [attributeDict objectForKey:@"href"];
        self.currentEntry.link = href;
    }
}

- (void)    parser:(NSXMLParser *)parser 
     didEndElement:(NSString *)elementName 
      namespaceURI:(NSString *)namespaceURI 
     qualifiedName:(NSString *)qName
{
    if([self.currentPath isEqualToString:@"/feed/entry"])
    {
        [_entries addObject:self.currentEntry];
        self.currentEntry = nil;
    }
    else if([self.currentPath isEqualToString:@"/feed/entry/title"])
    {
        self.currentEntry.title = self.currentText;
    }   
    else if([self.currentPath isEqualToString:@"/feed/entry/summary"])        
    {        
        self.currentEntry.summary = self.currentText;
    }    
    else if([self.currentPath isEqualToString:@"/feed/entry/content"])        
    {        
        self.currentEntry.content = self.currentText;
    }
    
    self.currentPath = [self.currentPath stringByDeletingLastPathComponent];
}

- (void)    parser:(NSXMLParser *)parser 
   foundCharacters:(NSString *)string
{
    [self.currentText appendString:string];
}

//- (void)    parser:(NSXMLParser *)parser 
//        foundCDATA:(NSData *)CDATABlock
//{
//}

- (void)    parser:(NSXMLParser *)parser 
parseErrorOccurred:(NSError *)parseError
{
}

#pragma mark Public
-(NSMutableArray*)parse
{
    _entries = [NSMutableArray array];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:_xmlData];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:YES];
    [parser parse];
    [parser release];
    return _entries;
}
@end

