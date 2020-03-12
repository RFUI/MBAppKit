/*!
 MBApplicationDelegate
 MBAppKit
 
 Copyright © 2018, 2020 RFUI.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import <RFKit/RFRuntime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 项目中可以重载这个类作为 AppDelegate
 
 主要功能是提供应用事件监听注册、分发。
 
 背景
 
 > 应用会有多个模块，模块间可能相互依赖，
 > 并假设这些模块不在启动时依次创建好，而是按需访问（这也是大型应用必须的）。
 >
 > NSApplicationDelegate 这么多通知调用的时机是不确定的，
 > 假如我们在 delegate 回调中创建这些模块，结果必然是模块创建时机不可控。
 >
 > 为了避免创建时序不确定带来的混乱，我们统一让模块创建后自己去添加监听事件。
 
 */
NS_AVAILABLE_MAC(10_13)
@interface MBApplicationDelegate : NSObject <
    NSApplicationDelegate
>

/**
 注册应用事件通知
 
 @warning 只有部分事件会通知 listener，见实现
 另外，多个模块的事件处理之间不应该有顺序依赖，否则可能会产生难以追查的 bug
 
 @param listener 内部会弱引用保存，对象释放无需手动调用移除
 */
- (void)addAppEventListener:(nullable __weak id<NSApplicationDelegate>)listener;

/**
 移除应用事件监听
 */
- (void)removeAppEventListener:(nullable id<NSApplicationDelegate>)listener;

/**
 遍历已注册的事件监听，可用于自定义通知的发送
 */
- (void)enumerateEventListenersUsingBlock:(NS_NOESCAPE void (^)(id<NSApplicationDelegate> listener))block;

/**
 重写了大部分常用 NSApplicationDelegate 事件，不会重写的有：
 
 - 带完成回调的方法
 - applicationShouldTerminate:
 - applicationShouldTerminateAfterLastWindowClosed:
 - application:delegateHandlesKey:
 - applicationWillFinishLaunching:
 - applicationDidFinishLaunching:
 
 子类如果重写下列方法，必须调用 super 以免破坏通知机制
 */

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls NS_REQUIRES_SUPER;

// open file 系列
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_REQUIRES_SUPER;
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_REQUIRES_SUPER;
- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary<NSString *, id> *)userInfo NS_REQUIRES_SUPER;

- (void)application:(NSApplication *)app willEncodeRestorableState:(NSCoder *)coder NS_REQUIRES_SUPER;
- (void)application:(NSApplication *)app didDecodeRestorableState:(NSCoder *)coder NS_REQUIRES_SUPER;

// Default NO
- (BOOL)application:(NSApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType NS_REQUIRES_SUPER;
- (void)application:(NSApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error NS_REQUIRES_SUPER;
- (void)application:(NSApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity NS_REQUIRES_SUPER;

- (void)application:(NSApplication *)application userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)metadata NS_REQUIRES_SUPER;

- (void)applicationWillHide:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidHide:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationWillUnhide:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidUnhide:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationWillBecomeActive:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidBecomeActive:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationWillResignActive:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidResignActive:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationWillUpdate:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidUpdate:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationWillTerminate:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidChangeScreenParameters:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationDidChangeOcclusionState:(NSNotification *)notification NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
