/*!
 MBEnvironment
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 环境状态标志

 其他状态应定义在 app 的代码中，可用 Swfit extension 去扩展

 @code
 extension MBENVFlag {
     /// 用户已登入
     static let userHasLogged = MBENVFlag(rawValue: 1 << 4)

     /// 本次启动当前用户的用户信息已成功获取过
     static let userInfoFetched = MBENVFlag(rawValue: 1 << 5)

     /// 导航已加载
     static let naigationLoaded = MBENVFlag(rawValue: 1 << 10)

     /// 主页已载入
     static let homeLoaded = MBENVFlag(rawValue: 1 << 11)
 }
 @endcode
 */
typedef NS_OPTIONS(int64_t, MBENVFlag) {
    MBENVFlagNone = 0
};

/**
 状态管理 manager
 
 背景
 -----
 
    之前为了解决模块互相依赖，防止互相创建导致死循环发生，把模块创建跟调用通过监听的方式分离开来。既然代码不能主动创建模块了，如果调用时模块不存在怎么办，如果依赖多个模块又怎么写？
 
    同时，我们希望业务能跟模块代码分开，设想登录成功后用户模块要调一大堆的业务代码会有多难看。那这些业务逻辑又能在哪里写，由谁去调用呢？
 
    MBEnvironment 就是为了解决上面两个问题存在的，它可以通过指定多个状态，当这些状态同时满足时做给定的事。

 */
@interface MBEnvironment : NSObject

/**
 状态监听回调执行的队列
 
 默认在主线程队列
 */
@property (nonatomic, null_resettable) dispatch_queue_t queue;

/// 当前状态是否满足指定状态
- (BOOL)meetFlags:(MBENVFlag)flags;

/// 标记状态开启
- (void)setFlagOn:(MBENVFlag)flag;

/// 标记状态关闭
- (void)setFlagOff:(MBENVFlag)flag;

#pragma mark -

/**
 若状态符合指定状态，立即执行一个 block，否则等待直到状态满足时执行

 @param flags 需要的状态
 @param block 如果调用方法时状态符合，block 将在当前线程调用；block 若没有立即调用，之后会在 queue 队列调用
 @param timeout 等待状态符合的最长时间，超出后将不等待立即执行，0 无限制，一直等待
 */
- (void)waitFlags:(MBENVFlag)flags do:(nonnull dispatch_block_t)block timeout:(NSTimeInterval)timeout;

#pragma mark - 监听

/**
 注册一个状态变化的监听，每次状态从不符合变化到符合时调用
 
 如果注册时当前状态符合指定的状态，并不会调用回调

 @param flags 需要的状态
 @param handler 状态从不符合变化到符合时调用的回调，在 queue 队列调用
 @return 监听辅助对象，用于移除监听
 */
- (nonnull id)registerFlagsObserver:(MBENVFlag)flags handler:(nonnull dispatch_block_t)handler;

/**
 移除状态监听

 @param observer 注册监听时返回的辅助对象
 */
- (void)removeFlagsObserver:(nullable id)observer;

#pragma mark - 静态状态响应

/**
 关于静态状态响应
 ------

 有时应用需要在一些固定的时机执行固定的逻辑，如果用上面的监听注册方法，可能没有一个特别好地方去写注册代码。
 比如：在联网、用户已登入且应用在前台的情况下后台执行数据的同步，如果用 MBWorker 可能不需要一个数据同步管理类，但放在网络、用户模块又不合适。

 使用静态注册可以在 MBEnvironment 的扩展中统一管理这类注册。
 */

/**
 注册静态状态响应

 @param flags 需要的状态
 @param selector 满足状态时调用的 MBEnvironment 中的方法
 @param handleOnce 调用一次后移除
 */
+ (void)staticObserveFlag:(MBENVFlag)flags selector:(nonnull SEL)selector handleOnce:(BOOL)handleOnce;

/**
 注册应用默认的环境，默认环境当状态变化时会调用静态监听
 */
+ (void)setAsApplicationDefaultEnvironment:(nonnull MBEnvironment *)env;

@end
