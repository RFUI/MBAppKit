/*!
 MBAPI
 
 Copyright © 2018 RFUI. All rights reserved.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import "RFAPI.h"
#import "AFHTTPRequestOperation.h"

/**
 MBAPI 在 RFAPI 的基础上，
 
 - 设置队列并发数为 5
 - 设置了响应处理的后台队列
 - 基于 view controller 的请求管理
 - 便捷状态提醒方法，使用 networkActivityIndicatorManager
 
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

/**
 取消属于 viewController 的请求，这些请求必须用 viewController 的类名做为 groupIdentifier
 */
+ (void)cancelOperationsWithViewController:(nullable id)viewController;

#pragma mark - 状态提醒

/**
 显示一个操作成功的信息，显示一段时间后自动隐藏
 */
+ (void)showSuccessStatus:(nullable NSString *)message;

/**
 显示一个错误提醒，一段时间后自动隐藏
 */
+ (void)showErrorStatus:(nullable NSString *)message;

/**
 显示一个操作失败的错误消息，显示一段时间后自动隐藏
 */
+ (void)alertError:(nullable NSError *)error title:(nullable NSString *)title;

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
