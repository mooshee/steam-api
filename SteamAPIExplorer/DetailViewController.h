//
//  DetailViewController.h
//  SteamAPIExplorer
//
//  Created by Daniel Hallman on 9/15/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

