/*!
 MBAPI
 
 Copyright © 2018 RFUI. All rights reserved.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFAPI/RFAPI.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

/**
 MBAPI 在 RFAPI 的基础上，
 
 - 设置队列并发数为 5
 - 设置了响应处理的后台队列
 - 基于 view controller 的请求管理
 
 使用
 
 应用应该创建 MBAPI 的子类，推荐在 onInit 中进行如下设置：
 
 1. 载入 API defines
 2. 设置 defineManager 的 defaultRequestSerializer 和 defaultResponseSerializer
 3. 设置 networkActivityIndicatorManager
 
 根据具体业务写相应的 defaultResponseSerializer 子类和 networkActivityIndicatorManager 子类。
 */
@interface MBAPI : RFAPI

@property (nullable, class) __kindof MBAPI *global;

/**
 从一个 plist 文件中载入接口定义
 
 Plist 例子：
 @code
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
     <key>DEFAULT</key>
     <dict>
         <key>Base</key>
         <string>http://example.com</string>
         <key>Path Prefix</key>
         <string>api/index?c=</string>
         <key>Method</key>
         <string>GET</string>
         <key>Authorization</key>
         <true/>
         <key>Cache Policy</key>
         <integer>0</integer>
         <key>Offline Policy</key>
         <integer>0</integer>
         <key>Expire</key>
         <string>60</string>
     </dict>
     <key>User Login</key>
     <dict>
         <key>Path</key>
         <string>user/login</string>
         <key>Authorization</key>
         <false/>
         <key>Response Class</key>
         <string>UserInformation</string>
         <key>Response Type</key>
         <integer>2</integer>
     </dict>
     <key>@ 支持分组</key>
     <dict>
         <key>User Reset Password</key>
         <dict>
             <key>Path</key>
             <string>user/reset</string>
             <key>Authorization</key>
             <false/>
         </dict>
         <key>User Change Password</key>
         <dict>
             <key>Path</key>
             <string>user/password</string>
         </dict>
     </dict>
 </dict>
 </plist>
 @endcode
 
 如果接口比较多，可以使用分组字典，key 的名必须以 @ 开头
 */
- (void)setupAPIDefineWithPlistPath:(nonnull NSString *)path;

#pragma mark - 请求管理

/**
 
 @param APIName 接口名，同时会作为请求的 identifier
 @param viewController 请求所属视图，会取到它的 class 名作为请求的 groupIdentifier
 */
+ (nullable AFHTTPRequestOperation *)requestWithName:(nonnull NSString *)APIName parameters:(nullable NSDictionary *)parameters viewController:(nullable UIViewController *)viewController loadingMessage:(nullable NSString *)message modal:(BOOL)modal success:(nullable void (^)(AFHTTPRequestOperation *__nullable operation, id __nullable responseObject))success completion:(nullable void (^)(AFHTTPRequestOperation *__nullable operation))completion;

/**
 @param failure 为 nil 发生错误时自动弹出错误信息
 */
+ (nullable AFHTTPRequestOperation *)requestWithName:(nonnull NSString *)APIName parameters:(nullable NSDictionary *)parameters viewController:(nullable UIViewController *)viewController forceLoad:(BOOL)forceLoad loadingMessage:(nullable NSString *)message modal:(BOOL)modal success:(nullable void (^)(AFHTTPRequestOperation *__nullable operation, id __nullable responseObject))success failure:(nullable void (^)(AFHTTPRequestOperation *__nullable operation, NSError *__nonnull error))failure completion:(nullable void (^)(AFHTTPRequestOperation *__nullable operation))completion;

/**
 发送一个后台请求
 
 失败不会报错
 */
+ (void)backgroundRequestWithName:(nonnull NSString *)APIName parameters:(nullable NSDictionary *)parameters completion:(nullable void (^)(BOOL success, id __nullable responseObject, NSError *__nullable error))completion;

#pragma mark -

/**
 取消属于 viewController 的请求，这些请求必须用 viewController 的类名做为 groupIdentifier
 */
+ (void)cancelOperationsWithViewController:(nullable id)viewController;

#pragma mark 请求间隔

/**
 背景：
 
    有的界面需要每次进入都刷新，如果刷新的请求还在进行或刚刚刷新且不是数据失效必须重刷，那么就没必要再此刷新了。为了实现这个效果，vc 必须记录时间，判定与上次成功获取的时间间隔，加上检查是否正在进行，至少要存两个属性，逻辑完善的话至少 10 行左右。
 
    RequestInterval 机制就是为了简化、复用上述机制。内部用 APIGroupIdentifier 跟踪请求的 groud id
 
 使用：
 
 - vc 先调用 enableRequestIntervalForViewController:APIName: 注册
 - 一般在 viewWillAppear: 中调用 shouldRequestForViewController:minimalInterval: 检查是否应该发送请求
 - 请求成功时调用 setRequestIntervalForViewController:APIName: 更新记录
 - 需要强制刷新时可能需要调用 clearRequestIntervalForViewController:
 
 */

/**
 为给定 vc 启用 RequestInterval 机制，name 用于内部跟踪，以便区分哪个请求需要记录起始
 */
- (void)enableRequestIntervalForViewController:(nonnull id)viewController APIName:(nonnull NSString *)name;

/**
 记录给定 vc 给定接口最后一次成功获取的时间
 
 需要 vc 认为请求成功之后调用
 */
- (void)setRequestIntervalForViewController:(nonnull id)viewController APIName:(nonnull NSString *)name;

/**
 是否应当进行刷新操作，一般在 vc 显示时调用
 
 若 vc 记录了多个接口，只有当这些接口最近全没请求过，才会返回 YES
 
 @bug 请求实际完成到通知 vc 完成再调用 setRequestInterval 的这段时间里，不能阻挡新请求的发送
 */
- (BOOL)shouldRequestForViewController:(nonnull id)viewController minimalInterval:(NSTimeInterval)interval;

/**
 是否应当进行刷新操作，一般在 vc 显示时调用
 
 @bug 请求实际完成到通知 vc 完成再调用 setRequestInterval 的这段时间里，不能阻挡新请求的发送
 
 @param APIName 检查特定接口，传空等同于调用 shouldRequestForViewController:minimalInterval:
 */
- (BOOL)shouldRequestForViewController:(nonnull id)viewController APIName:(nullable NSString *)APIName minimalInterval:(NSTimeInterval)interval;

/**
 重置给定 vc 的时间间隔记录
 */
- (void)clearRequestIntervalForViewController:(nonnull id)viewController;

@end


@interface UIViewController (MBAPIControl)

/**
 通常 API 发送的请求会传入一个 view controller 参数，用来把请求和 view controller 关联起来。
 这样，当页面销毁时，跟这个页面关联的未完成的请求可以被取消。
 
 关联的方式就是 APIGroupIdentifier 属性，默认是 view controller 的 class name。
 
 当 view controller 嵌套时，子控制器应该返回父控制器的 APIGroupIdentifier，以便整个页面销毁时，
 子控制器中的请求也可以被取消。
 */
@property (nonatomic, nonnull, copy) NSString *APIGroupIdentifier;

/// view controller 手动管理子 view controller 的 APIGroupIdentifier
@property (readonly) BOOL manageAPIGroupIdentifierManually;

@end
