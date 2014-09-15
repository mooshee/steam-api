//
//  SteamAPIClient.h
//  SteamAPI
//
//  Created by Daniel Hallman on 9/10/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef enum {
	SCAppIDTeamFortress2 = 440,
	SCAppIDTeamFortress2PublicBeta = 520,
	SCAppIDPortal2 = 620
} SCAppID;

@interface SteamAPIClient : AFHTTPSessionManager

@property (nonatomic, copy)	NSString *webAPIKey;

+ (instancetype)sharedClient;

#pragma mark - Generic API Methods

- (NSURLSessionDataTask *)getInterface:(NSString *)interface
								method:(NSString *)method
							   version:(NSUInteger)version
							parameters:(NSDictionary *)parameters
							completion:(void (^)(NSURLSessionDataTask *__unused task, id JSON, NSError *error))completion;

- (NSURLSessionDataTask *)postInterface:(NSString *)interface
								 method:(NSString *)method
								version:(NSUInteger)version
							 parameters:(NSDictionary *)parameters
							 completion:(void (^)(NSURLSessionDataTask *__unused task, id JSON, NSError *error))completion;

- (NSURLSessionDataTask *)httpMethod:(NSString *)httpmethod
						   interface:(NSString *)interface
							  method:(NSString *)method
							 version:(NSUInteger)version
						  parameters:(NSDictionary *)parameters
						  completion:(void (^)(NSURLSessionDataTask *__unused task, id JSON, NSError *error))completion;

#pragma mark - API Methods



@end
