//
//  BaseViewController.h
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/14.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^itemOperation)(NSIndexPath *indexPath);

@interface BaseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *dataArr;

/** 点击操作 */
@property (nonatomic, copy) itemOperation itemOperation;

@end

NS_ASSUME_NONNULL_END
