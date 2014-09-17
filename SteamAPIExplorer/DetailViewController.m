//
//  DetailViewController.m
//  SteamAPIExplorer
//
//  Created by Daniel Hallman on 9/15/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import "DetailViewController.h"

#import "SteamAPIClient.h"
#import "NSUserDefaults+Parameters.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger numParameters;
@property (nonatomic, strong) NSMutableArray *textFieldCells;
@property (nonatomic, strong) UITableViewCell *responseCell;
@property (nonatomic, assign) CGFloat responseHeight;

@end

@implementation DetailViewController


- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(executeRequest)];

	[self configureView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

- (void)executeRequest {
	NSMutableDictionary *parameters = [@{} mutableCopy];
	for (int i=0; i<self.numParameters; i++) {
		NSDictionary *parameter = self.detailItem[@"parameters"][i];
		UITableViewCell *cell = self.textFieldCells[i];
		UITextField *textField = (UITextField *)[cell.contentView viewWithTag:9];
		
		if (textField.text.length) {
			parameters[parameter[@"name"]] = textField.text;
		}
	}
	
	[[SteamAPIClient sharedClient] httpMethod:_detailItem[@"httpmethod"]
									interface:_detailItem[@"interface"]
									   method:_detailItem[@"name"]
									  version:[_detailItem[@"version"] integerValue]
								   parameters:parameters
								   completion:^(NSURLSessionDataTask *task, id JSON, NSError *error)
	 {
		 if ([task.originalRequest.HTTPMethod isEqualToString:@"GET"]) {
			 NSLog(@"%@ %@\n%@ %@", task.originalRequest.HTTPMethod, task.originalRequest.URL.absoluteString, JSON, error);
		 } else {
			 NSLog(@"%@ %@ %@\n%@ %@", task.originalRequest.HTTPMethod, task.originalRequest.URL.absoluteString, parameters, JSON, error);
		 }
		 
		 dispatch_async(dispatch_get_main_queue(), ^{
			 UITextView *textView = (UITextView *)[self.responseCell viewWithTag:9];
			 if (JSON) {
				 NSData *data = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil];
				 textView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			 } else {
				 textView.text = [error description];
			 }
			 
			 [textView sizeToFit];
			 self.responseHeight = textView.bounds.size.height;
			 
			 UILabel *headerLabel = [[UILabel alloc] init];
			 headerLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
			 headerLabel.numberOfLines = 0;
			 headerLabel.text = [NSString stringWithFormat:@"%@ %@", task.originalRequest.HTTPMethod, task.originalRequest.URL.absoluteString];
			 
			 NSDictionary *attributes = @{ NSFontAttributeName: headerLabel.font};
			 CGFloat labelWidth = self.tableView.bounds.size.width - 20.0;
			 CGRect labelRect = [headerLabel.text boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX)
															   options:NSStringDrawingUsesLineFragmentOrigin
															attributes:attributes
															   context:nil];
			 labelRect.origin.x = 10.0;
			 labelRect.origin.y	= 10.0;
			 headerLabel.frame = labelRect;
			 
			 UIView *header = [[UIView alloc] init];
			 header.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, labelRect.size.height + 10.0);
			 [header addSubview:headerLabel];
			 
			 self.tableView.tableHeaderView = header;
			 
			 [self.tableView beginUpdates];
			 [self.tableView endUpdates];
			 
			 // Scroll response textview to the top
			 [textView scrollRangeToVisible:NSMakeRange(0, 1)];
			 
			 // Scroll down to the text view
			 NSIndexPath *responseIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.numParameters];
			 [self.tableView scrollToRowAtIndexPath:responseIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
		 });
	 }];
}

- (void)configureView {
	// Update the user interface for the detail item.
	if (self.detailItem)
	{
		
		
	}
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
	if (_detailItem != newDetailItem) {
	    _detailItem = newDetailItem;
		
		self.title = _detailItem[@"name"];
		self.numParameters = [self.detailItem[@"parameters"] count];
		
		[self configureView];

		BOOL hasRequiredParameter = NO;
		_textFieldCells = [NSMutableArray array];
		NSDictionary *defaultParameters = [[NSUserDefaults standardUserDefaults] defaultParameters];
		
		for (NSDictionary *parameter in self.detailItem[@"parameters"]) {
			if (![parameter[@"optional"] boolValue]) {
				hasRequiredParameter = YES;
			}
			
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextfieldCell"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UITextField *textField = [[UITextField alloc] init];
			textField.translatesAutoresizingMaskIntoConstraints = NO;
			textField.tag = 9;
			textField.placeholder = [parameter[@"optional"] boolValue] ? @"optional" : @"required";
			[cell.contentView addSubview:textField];
			
			// Look for defaults
			id defaultValue = defaultParameters[parameter[@"name"]];
			if (defaultValue) {
				textField.text = [defaultValue respondsToSelector:@selector(stringValue)] ? [defaultValue stringValue] : [defaultValue description];
			}
			
			NSDictionary *views = NSDictionaryOfVariableBindings(textField);
			[cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[textField]-20-|" options:0 metrics:nil views:views]];
			[cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[textField]-10-|" options:0 metrics:nil views:views]];
			
			[_textFieldCells addObject:cell];
		}
		
		/*
		 * Create Response cell
		 */
		
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResponseCell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UITextView *textView = [[UITextView alloc] init];
		textView.translatesAutoresizingMaskIntoConstraints = NO;
		textView.tag = 9;
		[cell.contentView addSubview:textView];
		
		NSDictionary *views = NSDictionaryOfVariableBindings(textView);
		[cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:0 metrics:nil views:views]];
		[cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|" options:0 metrics:nil views:views]];
		
		self.responseCell = cell;
		
		if (!hasRequiredParameter) {
			[self executeRequest];
		}
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return [self.detailItem[@"parameters"] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == self.numParameters) {
		cell = self.responseCell;
	} else {
		cell = self.textFieldCells[indexPath.section];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == self.numParameters) {
		return MIN(self.responseHeight, tableView.bounds.size.height - 100);
	} else {
		return 44.0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == self.numParameters) {
		return @"Response";
	} else {
		NSDictionary *parameter = self.detailItem[@"parameters"][section];
		return [NSString stringWithFormat:@"%@ (%@)", parameter[@"name"], parameter[@"type"]];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return section == self.numParameters ? nil : self.detailItem[@"parameters"][section][@"description"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	NSString *text = [self tableView:tableView titleForFooterInSection:section];
	CGSize maxSize = CGSizeMake(tableView.bounds.size.width, 999999.0);
	UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	int height = 0;
	
	NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
										  font, NSFontAttributeName,
										  nil];
	
	CGRect frame = [text boundingRectWithSize:maxSize
									  options:NSStringDrawingUsesLineFragmentOrigin
								   attributes:attributesDictionary
									  context:nil];
	height = frame.size.height;
	
	return height+15;
}


@end
