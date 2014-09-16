//
//  NSUserDefaults+Parameters.h
//  SteamAPI
//
//  Created by Daniel Hallman on 9/15/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Parameters)

- (NSDictionary *)defaultParameters;
- (id)valueforDefaultParameter:(NSString *)key;
- (void)setDefaultParameterValue:(NSString *)value forKey:(NSString *)key;

@end
