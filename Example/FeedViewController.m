//
//  CategoryViewController.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/14/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedParser.h"
#import "FeedEntry.h"

#import "JSON.h"
#import "GTMNSString+HTML.h"

#define FEED_BY_ATOM 0

/////////////////////////////////////////////////////////////////////////////////////////////
@interface NSString (FeedParser)
- (NSString *)stringByConvertingHTMLToPlainText;
@end


@implementation FeedViewController

#pragma mark NSObject
@synthesize entries = _entries;
@synthesize unreadOnly = _unreadOnly;

- (id)initWithItem:(PLGRSubscriptionItem *)item
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _item = [item retain];
        _googleReader = [[PLGoogleReader defaultGoogleReader] retain];
        self.title = _item.title;        
        self.entries = [NSMutableArray array];
       
        _fontTitle = [[UIFont systemFontOfSize:18] retain];
        _fontSubtitle = [[UIFont systemFontOfSize:14] retain];
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.navigationItem.rightBarButtonItem = 
            [[[UIBarButtonItem alloc] initWithCustomView:_spinner] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_item release];
    [_googleReader release];
    [_entries release];    
    [_fontTitle release];
    [_fontSubtitle release];
    [_spinner release];    
    
    if (_request) {
        [_request cancel];
        [_request release];
        _request = nil;
    }
    
    [super dealloc];
}

#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [super viewDidAppear:animated];
    
    // Get the item asynchronously                                   
    if(_unreadOnly)
    {
        [params setObject:@"user/-/state/com.google/read" forKey:@"xt"];
    }

    
#if FEED_BY_ATOM        
    _request = [[_googleReader requestWithAtomPath:_item.streamid
                                        withParams:params
                                      withDelegate:self] retain];
#else
    _request = [[_googleReader requestWithStreamContents:_item.streamid 
                                              withParams:params
                                            withDelegate:self] retain];    
#endif    
    [_request connect];
    [_spinner startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];    
    if(_request)
    {
        [_request cancel];
        [_request release];
        _request = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark PLGRRequestDelegate
- (void)handleStreamContentsRequest:(id)resultData
{
    NSMutableArray* entries = [NSMutableArray array];
    id resultItems = [resultData objectForKey:@"items"];
    
    for(id resultItem in resultItems)
    {
        FeedEntry* entry = [[FeedEntry alloc] init];
        entry.entryid = [resultItem objectForKey:@"id"];
        entry.title   = [resultItem objectForKey:@"title"];
        entry.summary = [[resultItem objectForKey:@"summary"] objectForKey:@"content"];
        entry.content = [[resultItem objectForKey:@"content"] objectForKey:@"content"];
        id resultCategories = [resultItem objectForKey:@"categories"];
        if(resultCategories)
        {
            for(NSString* resultCategory in resultCategories)
            {
                if([resultCategory hasSuffix:@"/state/com.google/read"])
                {
                    entry.isRead = YES;
                }
            }
        }
        [entries addObject:entry];
        [entry release];
    }
    
    self.entries = entries;
}

- (void)request:(PLGRRequest*)request didLoad:(NSData*)data
{        		
#if FEED_BY_ATOM        
    FeedParser* parser = [[FeedParser alloc] initWithXMLData:data];
    self.entries = [parser parse];
    [parser release];    
#else
    NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];        
    id resultData = [result JSONValue];
    [self handleStreamContentsRequest:resultData];
#endif
    
    [_request release];
    _request = nil;
    [_spinner stopAnimating];        
    
    [self.tableView reloadData];
}

- (void)request:(PLGRRequest*)request didFailWithError:(NSError*)error
{
    [_request release];
    _request = nil; 
    [_spinner stopAnimating];    
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];        
        cell.detailTextLabel.numberOfLines = 3;         
    }    

    FeedEntry* entry = [_entries objectAtIndex:indexPath.row];        
    cell.textLabel.text = entry.title;
    cell.detailTextLabel.text = [entry.content ? entry.content : entry.summary stringByConvertingHTMLToPlainText];    
    
    // cell background color
    if(indexPath.row % 2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    }            

    // read or unread
    if(entry.isRead)
    {
        cell.imageView.image = [UIImage imageNamed:@"read.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"unread.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedEntry* item = [_entries objectAtIndex:indexPath.row];        
    CGFloat width = 300;
    CGFloat height = 16;  //padding for top and bottom
    CGSize size;    
    NSString* subtitle = item.content ? item.content : item.summary;

    // title height
    height += _fontTitle.lineHeight;
    
    size = [subtitle sizeWithFont:_fontSubtitle
                constrainedToSize:CGSizeMake(width, 3 * _fontSubtitle.lineHeight)
                    lineBreakMode:UILineBreakModeWordWrap];
    height += size.height;
    
    return height;    
}

@end


////////////////////////////////////////////////////////////////////////
#pragma mark - NSString (FeedParser)
@implementation NSString (FeedParser)
- (NSString *)stringByConvertingHTMLToPlainText {
    
	// Character sets
	NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]; /**/
    
	// Scan and find all tags
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:self.length];
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:YES];
	NSString *str = nil, *tagName = nil;
	BOOL dontReplaceTagWithSpace = NO;
	do {
        
		// Scan up to the start of a tag or whitespace
		if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
			[result appendString:str];
			str = nil; // reset
		}
        
		// Check if we've stopped at a tag/comment or whitespace
		if ([scanner scanString:@"<" intoString:NULL]) {
            
			// Stopped at a comment or tag
			if ([scanner scanString:@"!--" intoString:NULL]) {
                
				// Comment
				[scanner scanUpToString:@"-->" intoString:NULL]; 
				[scanner scanString:@"-->" intoString:NULL];
                
			} else {
                
				// Tag - remove and replace with space unless it's
				// a closing inline tag then dont replace with a space
				if ([scanner scanString:@"/" intoString:NULL]) {
                    
					// Closing tag - replace with space unless it's inline
					tagName = nil; dontReplaceTagWithSpace = NO;
					if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
						tagName = [tagName lowercaseString];
						dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
												   [tagName isEqualToString:@"b"] ||
												   [tagName isEqualToString:@"i"] ||
												   [tagName isEqualToString:@"q"] ||
												   [tagName isEqualToString:@"span"] ||
												   [tagName isEqualToString:@"em"] ||
												   [tagName isEqualToString:@"strong"] ||
												   [tagName isEqualToString:@"cite"] ||
												   [tagName isEqualToString:@"abbr"] ||
												   [tagName isEqualToString:@"acronym"] ||
												   [tagName isEqualToString:@"label"]);
					}
                    
					// Replace tag with string unless it was an inline
					if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                    
				}
                
				// Scan past tag
				[scanner scanUpToString:@">" intoString:NULL];
				[scanner scanString:@">" intoString:NULL];
                
			}
            
		} else {
            
			// Stopped at whitespace - replace all whitespace and newlines with a space
			if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
				if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
			}
            
		}
        
	} while (![scanner isAtEnd]);
    
	// Cleanup
	[scanner release];
    
	// Decode HTML entities and return
	NSString *retString = [NSString stringWithString:[result gtm_stringByUnescapingFromHTML]];
	[result release];
	return retString;
    
}
@end
