//
//  SteamAPIClient.m
//  SteamAPI
//
//  Created by Daniel Hallman on 9/10/14.
//  Copyright (c) 2014 Grepstar LLC. All rights reserved.
//

#import "SteamAPIClient.h"

static NSString * const SteamAPIBaseURLString = @"https://api.steampowered.com/";

@implementation SteamAPIClient

+ (instancetype)sharedClient {
	static SteamAPIClient *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedClient = [[SteamAPIClient alloc] initWithBaseURL:[NSURL URLWithString:SteamAPIBaseURLString]];
		_sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
		
#if TESTING
		_sharedClient.webAPIKey = @"0AB0F0500751013BD389CA61ED76222C";
#endif
		
	});
	
	return _sharedClient;
}

- (NSURLSessionDataTask *)getInterface:(NSString *)interface
								method:(NSString *)method
							   version:(NSUInteger)version
							parameters:(NSDictionary *)parameters
							completion:(void (^)(NSURLSessionDataTask *__unused task, id JSON, NSError *error))completion
{
	return [self httpMethod:@"GET" interface:interface method:method version:version parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)postInterface:(NSString *)interface
								method:(NSString *)method
							   version:(NSUInteger)version
							parameters:(NSDictionary *)parameters
							completion:(void (^)(NSURLSessionDataTask *__unused task, id JSON, NSError *error))completion
{
	return [self httpMethod:@"POST" interface:interface method:method version:version parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)httpMethod:(NSString *)httpmethod
						   interface:(NSString *)interface
							  method:(NSString *)method
							 version:(NSUInteger)version
						  parameters:(NSDictionary *)parameters
						  completion:(void (^)(NSURLSessionDataTask *, id, NSError *))completion
{
	NSString *versionString = [NSString stringWithFormat:@"v%04lu", (unsigned long)version];
	NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", interface, method, versionString];
	
	NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
	mutableParameters[@"key"] = [self webAPIKey];
	
	NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:httpmethod
														URLString:urlString
													   parameters:mutableParameters
														  success:^(NSURLSessionDataTask *task, id responseObject)
	{
	  if (completion) {
		  completion(task, responseObject, nil);
	  }
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
	  if (completion) {
		  completion(task, nil, error);
	  }
	}];
	
	[dataTask resume];
	
	return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
									   URLString:(NSString *)URLString
									  parameters:(id)parameters
										 success:(void (^)(NSURLSessionDataTask *, id))success
										 failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
	NSError *serializationError = nil;
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
	if (serializationError) {
		if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
			dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
				failure(nil, serializationError);
			});
#pragma clang diagnostic pop
		}
		
		return nil;
	}
	
	__block NSURLSessionDataTask *dataTask = nil;
	dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
		if (error) {
			if (failure) {
				failure(dataTask, error);
			}
		} else {
			if (success) {
				success(dataTask, responseObject);
			}
		}
	}];
	
	return dataTask;
}

#pragma mark - API Calls

+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block {
	return [[SteamAPIClient sharedClient] GET:@"stream/0/posts/stream/global" parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
		NSArray *postsFromResponse = [JSON valueForKeyPath:@"data"];
		NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
//		for (NSDictionary *attributes in postsFromResponse) {
//			Post *post = [[Post alloc] initWithAttributes:attributes];
//			[mutablePosts addObject:post];
//		}
//		
		if (block) {
			block([NSArray arrayWithArray:mutablePosts], nil);
		}
	} failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
		if (block) {
			block([NSArray array], error);
		}
	}];
}

@end
