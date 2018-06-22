/*!
 MBNavigationController
 MBAppKit
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFAlpha/RFNavigationController.h>
#import <RFAlpha/RFNavigationControllerTransitionDelegate.h>

@class MBNavigationOperation;

/**
 根导航控制器
 */
@interface MBNavigationController : RFNavigationController

/**
 隐藏导航返回按钮的文字
 
 在 didShowViewController 中设置当前 vc 的返回按钮
 */
@property IBInspectable BOOL prefersBackBarButtonTitleHidden;

#pragma mark - 导航队列

/// 导航弹框操作队列
@property (nonnull, readonly) NSMutableArray<__kindof MBNavigationOperation *> *operationQueue;

/// 尝试立即处理导航队列
- (void)setNeedsPerformNavigationOperation;

/// 可以执行低优先级的导航操作
@property (readonly) BOOL shouldPerfromQunedQperation;

#pragma mark -

- (void)applicationDidBecomeActive:(nonnull UIApplication *)application NS_REQUIRES_SUPER;
- (void)navigationController:(nonnull UINavigationController *)navigationController didShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;

@end

/**
 用于标记视图属于一个流程，
 处于流程中时，通过导航的弹窗和部分跳转将不会执行
 */
@protocol UIViewControllerIsFlowScence <NSObject>
@end


#pragma mark - 堆栈管理

@interface MBNavigationController (StackManagement)

/**
 有 view controller 从导航堆栈中移除时调用
 
 默认实现会把这些 view controller 相关联的 API 请求取消
 */
- (void)didRemoveViewControllers:(nonnull NSArray<UIViewController *> *)vcs NS_REQUIRES_SUPER;

/**
 便于在 IB 中调用 popViewControllerAnimated()
 */
- (IBAction)navigationPop:(id _Nullable)sender;

/**
 导航堆栈正在修改时再尝试变更堆栈，操作可能会失败。用这个方法会在转场动画结束后再执行变更操作
 
 注意这个方法不防 block 中有连续操作，嵌套执行 changeNavigationStack: 也会失败。
 */
- (void)changeNavigationStack:(void (^__nonnull)(MBNavigationController *__nonnull))block;

/**
 从栈顶依次弹出符合给定协议声明的视图，直到一个不是的
 */
- (void)popViewControllersOfScence:(nonnull Protocol *)aProtocol;

@end

#pragma mark - 基于每个页面的登入控制

@interface UIViewController (MBUserLoginRequired)

/**
 标记这个 vc 需要登录才能查看
 */
@property IBInspectable BOOL MBUserLoginRequired;
@end

@interface MBNavigationController (MBUserLoginRequired)

/**
 被需要登入阻塞 push 的 vc，登入成功后需要根据业务需要手动还原或者丢弃
 
 push 时界面需要登入时内部押入这个变量
 */
@property (nullable) UIViewController *loginSuspendedViewController;

/**
 需要重写，根据业务决定如何把登入页面展示出来
 
 外部不应手动调用
 */
- (void)presentLoginScene;
@end

/**
 导航 push 需要登入查看的页面时已自动处理。
 当一个操作需要登入时，可以先调用这个方法手动检查，并在需要时显示登入界面
 
 @return 已登入返回 NO，未登入返回 YES
 */
FOUNDATION_EXPORT BOOL MBOperationLoginRequired(void);

/**
 MBOperationLoginRequired() 的便捷宏
 
 参数是用户未登入时的返回值
 */
#define UserLoginRequired(RETURN) \
if (MBOperationLoginRequired()) return RETURN;

#import "MBNavigationOperation.h"
