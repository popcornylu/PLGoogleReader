//
//  CategoryViewController.h
//  PLGoogleReader
//
//  Created by popcornylu on 6/14/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReader.h"

@interface CategoryViewController : UITableViewController {
    PLGRSubscriptionItem* _category;
    PLGoogleReader*       _googleReader;    
    
    NSMutableArray*       _itemsSelf;
    NSMutableArray*       _items;
}

- (id)initWithCategroy:(PLGRSubscriptionItem*)category;

@end
