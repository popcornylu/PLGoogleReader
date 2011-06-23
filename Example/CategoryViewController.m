//
//  CategoryViewController.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/14/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "CategoryViewController.h"
#import "FeedViewController.h"
enum
{
    CategoryViewControllerIndexAll,
    CategoryViewControllerIndexUnread,    
    CategoryViewControllerIndexStarred,
    CategoryViewControllerIndexLiked,
    CategoryViewControllerIndexBroadcast,
    CategoryViewControllerIndexCount
};

@implementation CategoryViewController

#pragma mark NSObject
- (id)init
{
    return [self initWithCategroy:nil];
}

- (id)initWithCategroy:(PLGRSubscriptionItem*)category;
{
    self = [super initWithStyle:UITableViewStylePlain];        
   
    if (self) {
        _googleReader = [[PLGoogleReader defaultGoogleReader] retain];        
        
        if(!category)
        {
            // Root category
            _itemsSelf = [[NSMutableArray alloc] initWithObjects:
                          [PLGRSubscriptionItem itemWithStreamId:@"user/-/state/com.google/reading-list" andTitle:@"All items"], 
                          [PLGRSubscriptionItem itemWithStreamId:@"user/-/state/com.google/reading-list" andTitle:@"Unread items"], 
                          [PLGRSubscriptionItem itemWithStreamId:@"user/-/state/com.google/starred" andTitle:@"Starred items"], 
                          [PLGRSubscriptionItem itemWithStreamId:@"user/-/state/com.google/like" andTitle:@"Liked items"], 
                          [PLGRSubscriptionItem itemWithStreamId:@"user/-/state/com.google/broadcast" andTitle:@"Shared items"], 
                          nil];
            _items = [[[_googleReader subscription] sortedListForTag:nil] retain];
        }
        else
        {                   
            // Category of a label
            _category = [category retain];                                                                      
            _items = [[[_googleReader subscription] sortedListForTag:category.streamid] retain];
        }
        
        self.title = _category.title;
    }
    return self;
}

- (void)dealloc
{
    [_category release];
    [_googleReader release];
    [_itemsSelf release];
    [_items release];    
    
    [super dealloc];
}

#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_category)
    {
        if(section == 0)
        {
            return @"Label";
        }
        else
        {
            return @"Feeds";
        }
    }
    else
    {
        if(section == 0)
        {        
            return @"Self";            
        }
        else
        {
            return @"Subscription";
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_category)
    {
        if(section == 0)
        {
            return 1;
        }
        else
        {
            return [_items count];
        }
    }
    else
    {
        if(section == 0)
        {
            return [_itemsSelf count];
        }
        else
        {
            return [_items count];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    }

    // Get the item for current index path.
    PLGRSubscriptionItem* item = nil;     
    if(indexPath.section == 0)        
    {
        if(_category)
        {   
            item = _category;
        }
        else
        {
            item = [_itemsSelf objectAtIndex:indexPath.row];            
        }
    }
    else
    {
        item = [_items objectAtIndex:indexPath.row];        
    }
    
    // The title
    NSUInteger unreadCount = [[_googleReader subscription] unreadCountForTag:item.streamid];            
    if(unreadCount > 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", item.title, unreadCount];            
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", item.title];                            
    }            
    
    // The cell type
    if(indexPath.section == 1 && [item isLabel])
    {            
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;                            
    }
    else
    {            
        cell.accessoryType = UITableViewCellAccessoryNone;                                
    }
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLGRSubscriptionItem* item = nil;
    BOOL unreadOnly = NO;
    BOOL showCategory = NO;

    // Select the item to show.
    if(indexPath.section == 0)
    {
        if(_category)
        {                            
            item = _category;
        }
        else
        {
            item = [_itemsSelf objectAtIndex:indexPath.row];            
            if(indexPath.row == CategoryViewControllerIndexUnread)
            {
                unreadOnly = YES;
            }
        }
    }
    if(indexPath.section == 1)
    {            
        item = [_items objectAtIndex:indexPath.row];
        if([item isLabel])
        {
            showCategory = YES;
        }        
    }         

    // Push the view controller
    if(showCategory)
    {
        // Push by subscategroy
        CategoryViewController *viewController = [[CategoryViewController alloc] initWithCategroy:item];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];                  
    }
    else
    {
        // Push by showing this feed
        FeedViewController* viewController = [[FeedViewController alloc] initWithItem:item];
        viewController.unreadOnly = unreadOnly;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];        
    }
}

@end
