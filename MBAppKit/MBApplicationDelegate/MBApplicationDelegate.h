/*!
 MBApplicationDelegate
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
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
 > UIApplicationDelegate 这么多通知调用的时机是不确定的，
 > 假如我们在 delegate 回调中创建这些模块，结果必然是模块创建时机不可控。
 >
 > 为了避免创建时序不确定带来的混乱，我们统一让模块创建后自己去添加监听事件。

 */
API_AVAILABLE(ios(9.0), tvos(9.0))
@interface MBApplicationDelegate : UIResponder <
    UIApplicationDelegate
>

/**
 注册应用事件通知
 
 @warning 只有部分事件会通知 listener，见实现
 另外，多个模块的事件处理之间不应该有顺序依赖，否则可能会产生难以追查的 bug
 
 @param listener 内部会弱引用保存，对象释放无需手动调用移除
 */
- (void)addAppEventListener:(nullable __weak id<UIApplicationDelegate>)listener;

/**
 移除应用事件监听
 */
- (void)removeAppEventListener:(nullable id<UIApplicationDelegate>)listener;

#pragma mark - UIApplicationDelegate

@property (nonatomic) UIWindow *window;

/**
 重写了大部分 UIApplicationDelegate 的事件，不会重写的有：
 
 - iOS 9 以下废弃的方法
 - 带完成回调的方法
 - application:willFinishLaunchingWithOptions:
 - application:didFinishLaunchingWithOptions:
 - application:supportedInterfaceOrientationsForWindow:
 - application:shouldAllowExtensionPointIdentifier:
 - application:userDidAcceptCloudKitShareWithMetadata:
 
 - application:viewControllerWithRestorationIdentifierPath:coder:
 - application:shouldSaveApplicationState:
 - application:shouldRestoreApplicationState:
 - application:willEncodeRestorableStateWithCoder:
 - application:didDecodeRestorableStateWithCoder:
 
 - application:willContinueUserActivityWithType:
 - application:didFailToContinueUserActivityWithType:error:
 - application:didUpdateUserActivity:
 
 子类如果重写下列方法，必须调用 super 以免破坏通知机制
 */

- (void)applicationDidFinishLaunching:(nullable UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationDidBecomeActive:(nonnull UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillResignActive:(nonnull UIApplication *)application NS_REQUIRES_SUPER;

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_REQUIRES_SUPER;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillTerminate:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationSignificantTimeChange:(UIApplication *)application NS_REQUIRES_SUPER;

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame NS_REQUIRES_SUPER;

// iOS 10+ 替换
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_REQUIRES_SUPER;
// iOS 10+ 替换
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_REQUIRES_SUPER;
// iOS 10+ 替换
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification NS_REQUIRES_SUPER;

- (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_REQUIRES_SUPER;

- (void)applicationDidEnterBackground:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillEnterForeground:(UIApplication *)application NS_REQUIRES_SUPER;

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END

