//
//  MasterViewController.m
//  SteamAPIExplorer
//
//  Created by Daniel Hallman on 9/15/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SteamAPIClient.h"

@interface MasterViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *methods;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"API";
	self.searchResults = [NSMutableArray array];
	
	// Refresh
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[self.tableView addSubview:refreshControl];
	[refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refreshControl;
	
	// Search results
	UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	searchResultsController.tableView.dataSource = self;
	searchResultsController.tableView.delegate = self;
	
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
	
	self.searchController.searchResultsUpdater = self;
	
	self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
	
	self.tableView.tableHeaderView = self.searchController.searchBar;
	
	self.definesPresentationContext = YES;
	
	// Refresh
	[self refreshTable];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		UITableView *tableView = self.tableView;
		NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)sender];
		if (indexPath == nil) {
			tableView = [self searchResultsTableView];
			indexPath = [tableView indexPathForCell:(UITableViewCell *)sender];
		}
		
		NSDictionary *method = [self objectAtIndexPath:indexPath inTableView:tableView];
	    [[segue destinationViewController] setDetailItem:method];
	}
}

#pragma mark - Helper

- (UITableView *)searchResultsTableView {
	return ((UITableViewController *)self.searchController.searchResultsController).tableView;
}

- (NSDictionary *)objectAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	if (tableView == [self searchResultsTableView]) {
		return self.searchResults[indexPath.row];
	} else {
		return self.methods[indexPath.row];
	}
}

- (void)refreshTable {
	[[SteamAPIClient sharedClient] getInterface:@"ISteamWebAPIUtil"
										 method:@"GetSupportedAPIList"
										version:1
									 parameters:nil
									 completion:^(NSURLSessionDataTask *task, id JSON, NSError *error)
	 {
		 NSMutableArray *mutableMethods = [@[] mutableCopy];
		 
		 NSArray *interfaces = JSON[@"apilist"][@"interfaces"];
		 for (NSDictionary *interface in interfaces)
		 {
			 NSArray *methods = interface[@"methods"];
			 for (NSDictionary *method in methods)
			 {
				 NSMutableDictionary *mutableMethod = [NSMutableDictionary dictionaryWithDictionary:method];
				 mutableMethod[@"interface"] = interface[@"name"];
				 
				 //				 if ([method[@"name"] isEqualToString:@"GetSchemaURL"]) {
				 [mutableMethods addObject:mutableMethod];
				 //				 }
				 
				 
				 //				 NSLog(@"%@ %@ %@ %@ %@", method[@"httpmethod"], interface[@"name"], method[@"name"], method[@"version"], method[@"parameters"]);
			 }
		 }
		 
		 self.methods = mutableMethods;
		 
		 [self.refreshControl endRefreshing];
		 [self.tableView reloadData];
	 }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == [self searchResultsTableView]) {
		return 1;
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == [self searchResultsTableView]) {
		return [self.searchResults count];
	} else {
		return [self.methods count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	if (tableView == [self searchResultsTableView]) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
			cell.textLabel.font = [UIFont systemFontOfSize:12.0];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	}

	
	NSDictionary *method = [self objectAtIndexPath:indexPath inTableView:tableView];

	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", method[@"interface"], method[@"name"]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ version %@", method[@"httpmethod"], method[@"version"]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == [self searchResultsTableView]) {
		[self performSegueWithIdentifier:@"showDetail" sender:[tableView cellForRowAtIndexPath:indexPath]];
	}
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	
	NSString *searchText = [self.searchController.searchBar text];
	
	[self updateFilteredContentForSearchText:searchText];
	
	[[self searchResultsTableView] reloadData];
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForSearchText:(NSString *)searchText {
	
	// Update the filtered array based on the search text and scope.
	if ((searchText == nil) || [searchText length] == 0) {
		self.searchResults = [self.methods mutableCopy];
		return;
	}
	
	
	[self.searchResults removeAllObjects]; // First clear the filtered array.
	
	/*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *method in self.methods) {
		NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
		NSRange foundRange;
		
		foundRange = [method[@"name"] rangeOfString:searchText options:searchOptions];
		if (foundRange.length > 0) {
			[self.searchResults addObject:method];
			continue;
		}
		
		foundRange = [method[@"interface"] rangeOfString:searchText options:searchOptions];
		if (foundRange.length > 0) {
			[self.searchResults addObject:method];
			continue;
		}
	}
}


@end
