//
//  SteamAPITests.m
//  SteamAPI
//
//  Created by Daniel Hallman on 9/12/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SteamAPIClient.h"

@interface SteamAPITests : XCTestCase

@end

@implementation SteamAPITests

- (void)setUp {
    [super setUp];
	
	[[SteamAPIClient sharedClient] setWebAPIKey:@"0AB0F0500751013BD389CA61ED76222C"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testAPIList {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Steam API Call"];
	
	[[SteamAPIClient sharedClient] getInterface:@"ISteamWebAPIUtil"
										 method:@"GetSupportedAPIList"
										version:1
									 parameters:nil
									 completion:^(NSURLSessionDataTask *task, id JSON, NSError *error)
	 {
		 XCTAssertNil(error);
		 NSArray *interfaces = JSON[@"apilist"][@"interfaces"];
		 for (NSDictionary *interface in interfaces)
		 {
			 NSArray *methods = interface[@"methods"];
			 for (NSDictionary *method in methods)
			 {
//				 NSLog(@"%@ %@ %@ %@ %@", method[@"httpmethod"], interface[@"name"], method[@"name"], method[@"version"], method[@"parameters"]);

			 }
		 }
		 
		 [expectation fulfill];
	 }];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
		
	}];
}

- (void)testAPIPlayerSummaries {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Steam API Call"];
	
	[[SteamAPIClient sharedClient] getInterface:@"ISteamUser"
										 method:@"GetPlayerSummaries"
										version:2
									 parameters:@{ @"steamids" : @(76561197960435530) }
									 completion:^(NSURLSessionDataTask *task, id JSON, NSError *error)
	{
		XCTAssertNil(error);

		[expectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
		
	}];
}

- (void)testAPIFriendsList {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Steam API Call"];
	
	[[SteamAPIClient sharedClient] getInterface:@"ISteamUser"
										 method:@"GetFriendList"
										version:1
									 parameters:@{ @"steamid" : @(76561197960435530),
												   @"relationship" : @"friend" }
									 completion:^(NSURLSessionDataTask *task, id JSON, NSError *error)
	 {
		 XCTAssertNil(error);
		 
		 [expectation fulfill];
	 }];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
		
	}];
}

- (void)testAPIGetTradeOffers {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Steam API Call"];
	
	[[SteamAPIClient sharedClient] getInterface:@"IEconService"
										 method:@"GetTradeOffers"
										version:1
									 parameters:nil
									 completion:^(NSURLSessionDataTask *task, id JSON, NSError *error)
	 {
		 XCTAssertNil(error);
		 [self printJSON:JSON error:error];
		 [expectation fulfill];
	 }];
	
	[self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
		
	}];
}

#pragma mark - Helpers

- (void)printJSON:(id)JSON error:(NSError *)error {
	NSLog(@"\nJSON: %@\nerror: %@", JSON, error);
}

@end
