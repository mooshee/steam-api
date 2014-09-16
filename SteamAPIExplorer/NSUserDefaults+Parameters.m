//
//  NSUserDefaults+Parameters.m
//  SteamAPI
//
//  Created by Daniel Hallman on 9/15/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import "NSUserDefaults+Parameters.h"

@implementation NSUserDefaults (Parameters)

- (NSDictionary *)defaultParameters {
	NSDictionary *defaultParameters = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultParameters"];
	if (defaultParameters == nil) {
		defaultParameters = @{};
		[[NSUserDefaults standardUserDefaults] setObject:defaultParameters forKey:@"defaultParameters"];
	}
	return defaultParameters;
}

- (id)valueforDefaultParameter:(NSString *)key {
	return [self defaultParameters][key];
}

- (void)setDefaultParameterValue:(NSString *)value forKey:(NSString *)key {
	NSMutableDictionary *defaultParameters = [[self defaultParameters] mutableCopy];
	[defaultParameters setObject:value forKey:key];
	
	[[NSUserDefaults standardUserDefaults] setObject:defaultParameters forKey:@"defaultParameters"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
