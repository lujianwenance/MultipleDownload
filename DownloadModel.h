//
//  DownloadModel.h
//  NavigationBar_OC
//
//  Created by lujianwen on 25/03/2018.
//  Copyright © 2018 LU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DownloadModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@end
