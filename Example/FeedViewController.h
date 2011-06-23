//
//  ATOMViewController.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/14/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReader.h"

@interface FeedViewController : UITableViewController 
    <PLGRRequestDelegate>
{
    PLGRSubscriptionItem* _item;
    PLGoogleReader* _googleReader;
    NSMutableArray* _entries;
    UIFont* _fontTitle;
    UIFont* _fontSubtitle;    
    PLGRRequest* _request;
    UIActivityIndicatorView* _spinner;
    BOOL _unreadOnly;
}

@property (nonatomic) BOOL unreadOnly;
@property (nonatomic, retain) NSMutableArray* entries;
- (id) initWithItem:(PLGRSubscriptionItem*)item;



@end
