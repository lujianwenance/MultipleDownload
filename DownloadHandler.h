//
//  DownloadHandler.h
//  NavigationBar_OC
//
//  Created by lujianwen on 23/03/2018.
//  Copyright © 2018 LU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, DownloadState) {
    kDownloadResume,
    kDownloadfail,
    kDownloadSuccess,
};

@class DownloadHandler, ProgressTableViewCell;

@protocol DownloadHandlerDelegate <NSObject>

//- (void)downloadHandler:(DownloadHandler *)handler task:(NSURLSessionDownloadTask *)task downloadProgress:(NSProgress *)progress;
- (void)downloadHandler:(DownloadHandler *)hander complation:(NSURLSessionDownloadTask *)task;
- (void)downloadHandler:(DownloadHandler *)hander error:(NSError *)error;

@end

@interface DownloadHandler : NSObject

@property (nonatomic, strong) NSArray *downloadUrls;
@property (nonatomic, weak) id<DownloadHandlerDelegate> delegate;
@property (nonatomic, readonly, strong) NSArray *dataSource;
@property (nonatomic, readonly, assign) BOOL isRunning;

+ (instancetype)sharedHandler;

- (void)changeTaskState:(NSURLSessionDownloadTask *)task;

- (void)storeDownloadTaskIfNeeded;
- (void)downloadTaskIfNeeded;

@end
