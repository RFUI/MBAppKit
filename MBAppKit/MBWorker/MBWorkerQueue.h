/*!
 MBWorkerQueue
 
 Copyright © 2018 RFUI. All rights reserved.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd. All rights reserved.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import "RFUI.h"
#import "MBWorker.h"


/**
 MBWorker 要在一个队列中依次执行

 MBWorkerQueue 当前并未考虑可子类重写
 */
@interface MBWorkerQueue : NSObject <
    RFInitializing
>

/// work 执行线程，为空在主线程
@property (nullable) dispatch_queue_t dispatchQueue;

/// 暂停/恢复队列，正在执行的 work 并不会因这个属性的变化终止或继续
@property (nonatomic) BOOL suspended;

/// 当前执行中的 worker
@property (nonatomic, nullable, readonly) MBWorker *executingWorker;

/// 当前队列
- (nonnull NSArray<MBWorker *> *)currentWorkerQueue;

/**
 @param worker 如果 worker 已加入队列，将抛出异常
 */
- (void)addWorker:(nullable MBWorker *)worker;

@end
