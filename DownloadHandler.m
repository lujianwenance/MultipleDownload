//
//  DownloadHandler.m
//  NavigationBar_OC
//
//  Created by lujianwen on 23/03/2018.
//  Copyright © 2018 LU. All rights reserved.
//

#import "DownloadHandler.h"
#import "NSString+Hash.h"
#import "LUDownloadManager.h"
#import "DownloadModel.h"

@interface DownloadHandler ()

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableDictionary *tasksDic;

@end

@implementation DownloadHandler {
    LUDownLoadManager *_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[LUDownLoadManager alloc] init];
        _tasksDic = [NSMutableDictionary dictionary];
        _datas = [NSMutableArray array];
    }
    return self;
}

- (void)storeDownloadTaskIfNeeded {
    if (_datas.count) {
        for (DownloadModel *model in _datas) {
            [model.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                NSURL *documentsDirectoryURL = [[[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[model.task.currentRequest.URL absoluteString].md5String,@"download".md5String]];//
                NSDictionary *resumeDic = [NSDictionary dictionaryWithObject:resumeData forKey:model.urlString];
                if( [resumeDic writeToURL:documentsDirectoryURL atomically:YES]) {
                    NSLog(@"写入成功");
                } else {
                    NSLog(@"写入失败");
                }
            }];
        }
    }
}

- (void)downloadTaskIfNeeded {
    NSURL *documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryURL error:nil];
    for (NSString *fileName in files) {
        NSString *suffixString = @"download".md5String;
        if ([fileName containsString:suffixString]) {
            NSURL *url = [documentsDirectoryURL URLByAppendingPathComponent:fileName];
            NSDictionary *resumeDic = [NSDictionary dictionaryWithContentsOfURL:url];
            DownloadModel *model = [[DownloadModel alloc] init];
            model.title = [[NSFileManager defaultManager] displayNameAtPath:url.absoluteString];
            model.urlString = [[resumeDic allKeys] lastObject];
            model.task = [self resumTaskWithResumData:[[resumeDic allValues] lastObject] url:model.urlString];
            if (model.task) {
                [_datas addObject:model];
                [_tasksDic setObject:model forKey:model.urlString.md5String];
            }
        }
    }
}



+ (instancetype)sharedHandler {
    static DownloadHandler *handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[DownloadHandler alloc] init];
    });
    return handler;
}

- (void)setDownloadUrls:(NSArray *)downloadUrls {
    _downloadUrls = downloadUrls;
    for (NSString *urlString in downloadUrls) {
        DownloadModel *model = [[DownloadModel alloc] init];
        model.title = urlString.md5String;
        model.urlString = urlString;
        model.task = [self startTaskWithUrl:urlString];
        [_datas addObject:model];
        [_tasksDic setObject:model forKey:urlString.md5String];
    }
}

- (NSURLSessionDownloadTask *)startTaskWithUrl:(NSString *)urlString {
    __weak typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *task = [_manager downloadTaskURLString:urlString progress:^(NSProgress *downloadProgress) {
        DownloadModel *model = [weakSelf searchDownloadModelWithUrlString:urlString];
        model.progress = model ? downloadProgress.fractionCompleted : 0;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadHandler:error:)]) {
                [self.delegate downloadHandler:self error:error];
            }
        } else {
            
            DownloadModel *model = [weakSelf searchDownloadModelWithUrlString:urlString];
            [_datas removeObject:model];
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadHandler:complation:)]) {
                [self.delegate downloadHandler:self complation:nil];
            }
        }
    }];
    return task;
}

- (NSURLSessionDownloadTask *)resumTaskWithResumData:(NSData *)resumData url:(NSString *)urlString {
    __weak typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *task = [_manager downloadTaskResumData:resumData progress:^(NSProgress *downloadProgress) {
        DownloadModel *model = [weakSelf searchDownloadModelWithUrlString:urlString];
        model.progress = model ? downloadProgress.fractionCompleted : 0;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadHandler:error:)]) {
                [self.delegate downloadHandler:self error:error];
            }
        } else {
            
            DownloadModel *model = [weakSelf searchDownloadModelWithUrlString:urlString];
            [_datas removeObject:model];
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadHandler:complation:)]) {
                [self.delegate downloadHandler:self complation:nil];
            }
        }
    }];
    return task;
}

- (DownloadModel *)searchDownloadModelWithUrlString:(NSString *)urlString {
    DownloadModel *searchModel = self.tasksDic[urlString.md5String];
    for (DownloadModel *model in _datas) {
        if (model == searchModel) {
            return model;
        }
    }
    return nil;
}

- (void)changeTaskState:(NSURLSessionDownloadTask *)task {
    if (task.state == NSURLSessionTaskStateRunning) {
        [task suspend];
    } else if (task.state == NSURLSessionTaskStateSuspended) {
        [task resume];
    } else {
        NSLog(@"重新开始Task");
    }
}

- (NSArray *)dataSource {
    return [_datas copy];
}

- (BOOL)isRunning {
    return _datas.count;
}

@end
