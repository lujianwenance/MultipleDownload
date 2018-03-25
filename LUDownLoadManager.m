//
//  LUDownloadUploadManager.m
//  NavigationBar_OC
//
//  Created by lujianwen on 20/03/2018.
//  Copyright © 2018 LU. All rights reserved.
//

#import "LUDownLoadManager.h"
#import "AFNetworking.h"

@interface LUDownLoadManager ()

@end

@implementation LUDownLoadManager

+ (instancetype)sharedManager {
    static LUDownLoadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSURLSessionDownloadTask *)downloadTaskURLString:(NSString *)urlString progress:(void (^)(NSProgress *))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *, NSURL *, NSError *))completionHandler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    __block NSURLSessionDownloadTask *task = nil;
    task = [self downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:completionHandler];
    [task resume];
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskResumData:(NSData *)resumData
                                           progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                  completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {

    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    __block NSURLSessionDownloadTask *task = nil;
    task = [self downloadTaskWithResumeData:resumData progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:completionHandler];
    [task resume];
    return task;
}

@end




