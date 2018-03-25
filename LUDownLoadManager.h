//
//  LUDownloadUploadManager.h
//  NavigationBar_OC
//
//  Created by lujianwen on 20/03/2018.
//  Copyright © 2018 LU. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"


typedef void(^DataCompletionBlock)(id data, NSError* error);
typedef void(^ResultCompletionBlock)(BOOL success, NSError* error);

@interface LUDownLoadManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (NSURLSessionDownloadTask *)downloadTaskURLString:(NSString *)urlString
                                             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL * filePath, NSError * error))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskResumData:(NSData *)resumData
                                           progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                  completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
@end
