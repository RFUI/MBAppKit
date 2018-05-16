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

@end

/**
 用于标记视图属于一个流程，
 处于流程中时，通过导航的弹窗和部分跳转将不会执行
 */
@protocol UIViewControllerIsFlowScence <NSObject>
@end


#pragma mark - 堆栈管理

@interface MBNavigationController (StackManagement)

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

#import "MBNavigationOperation.h"
