
#import "MBNavigationController.h"
#import "MBApplicationDelegate.h"
#import "MBGeneralViewControllerStateTransitions.h"
#import "shadow.h"
#import <RFKit/UIResponder+RFKit.h>
#import <RFAlpha/RFSynthesizeCategoryProperty.h>

@interface MBNavigationController () <
    UIApplicationDelegate,
    UINavigationControllerDelegate
>
@property UIViewController *loginSuspendedViewController;
// 跳转到登入页了，被阻塞的页面也暂存了，但是用户之后退出登入，之前暂存的状态需要取消
// 这个变量辅助达到上述效果
@property (weak) UIViewController *_MBNavigationController_loginSuspendedVCKeeper;
@end

@implementation MBNavigationController

- (void)onInit {
    _operationQueue = [NSMutableArray arrayWithCapacity:10];
    [AppDelegate() addAppEventListener:self];
    [super onInit];
}

- (void)afterInit {
    [super afterInit];
    RFAssert(self.delegate == self, @"MBNavigationController’s delegate must be self");
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.navigationBarHidden) {
        return self.topViewController;
    }
    return nil;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UIViewController<MBGeneralViewControllerStateTransitions> *vc = (id)self.topViewController;
    if ([vc respondsToSelector:@selector(MBViewDidAppear:)]) {
        [vc MBViewDidAppear:NO];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super navigationController:navigationController didShowViewController:viewController animated:animated];

    if (self.prefersBackBarButtonTitleHidden) {
        if (!viewController.navigationItem.backBarButtonItem) {
            viewController.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    }
    if (self.loginSuspendedViewController) {
        BOOL keeperNotFound = YES;
        if (self.visibleViewController == self._MBNavigationController_loginSuspendedVCKeeper) {
            keeperNotFound = NO;
        }
        else {
            for (UIViewController *vc in self.viewControllers) {
                if (vc == self._MBNavigationController_loginSuspendedVCKeeper) {
                    keeperNotFound = NO;
                    break;
                }
            }
        }
        if (keeperNotFound) {
            self.loginSuspendedViewController = nil;
            self._MBNavigationController_loginSuspendedVCKeeper = nil;
        }
    }
    [self changeNavigationStack:^(MBNavigationController *this) {
        [this setNeedsPerformNavigationOperation];
    }];
}

#pragma mark - 导航队列

- (void)setNeedsPerformNavigationOperation {
    if (!self.operationQueue.count
        || !self.shouldPerfromQunedQperation) return;
    
    MBNavigationOperation *perfromedOp = nil;
    if ((perfromedOp = [self perfromedNavigationOperation])) {
        [self.operationQueue removeObject:perfromedOp];
        return;
    }
}

- (BOOL)shouldPerfromQunedQperation {
    if (self.transitionCoordinator) return NO;
    if (self.presentedViewController) return NO;
    
    // 键盘弹出忽略
    if (UIResponder.firstResponder) return NO;
    
    if ([self.topViewController conformsToProtocol:@protocol(UIViewControllerIsFlowScence)]) {
        return NO;
    }
    return YES;
}

- (nullable MBNavigationOperation *)perfromedNavigationOperation {
    id performedOp = nil;
    NSMutableArray *needsRemovedOps = nil;
    for (__kindof MBNavigationOperation *op in self.operationQueue) {
        NSArray<Class> *topVCClasses = op.topViewControllers;
        if (topVCClasses && ![topVCClasses containsObject:self.topViewController.class]) continue;
        
        if ([op perform:self]) {
            performedOp = op;
            break;
        }
        else {
            if (!needsRemovedOps) {
                needsRemovedOps = [NSMutableArray.alloc initWithCapacity:self.operationQueue.count];
            }
            [needsRemovedOps addObject:op];
        }
    } // END: each in operationQueue
    
    if (needsRemovedOps.count) {
        [self.operationQueue removeObjectsInArray:needsRemovedOps];
    }
    return performedOp;
}

@end

#pragma mark - StackManagement

@implementation MBNavigationController (StackManagement)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!AppUser()
        && viewController.MBUserLoginRequired) {
        self.loginSuspendedViewController = viewController;
        [self _MBNavigationController_tryLogin];
        return;
    }
    [super pushViewController:viewController animated:animated];
}

- (IBAction)navigationPop:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)changeNavigationStack:(void (^)(MBNavigationController * _Nonnull))block {
    id <UIViewControllerTransitionCoordinator> co = self.transitionCoordinator;
    if (!co) {
        block(self);
    }
    [co animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        block(self);
    }];
}

- (void)popViewControllersOfScence:(Protocol *)aProtocol {
    UIViewController *vc;
    for (UIViewController *obj in self.viewControllers.reverseObjectEnumerator) {
        if ([obj conformsToProtocol:aProtocol]) continue;
        vc = obj;
        break;
    }
    [self popToViewController:vc animated:YES];
}

- (void)_MBNavigationController_tryLogin {
    if (AppUser()) return;
    [self presentLoginScene];
    self._MBNavigationController_loginSuspendedVCKeeper =  self.visibleViewController;
}

@end

@implementation UIViewController (MBUserLoginRequired)
RFSynthesizeCategoryBoolProperty(MBUserLoginRequired, setMBUserLoginRequired);
@end

@implementation MBNavigationController (MBUserLoginRequired)
@dynamic loginSuspendedViewController;

- (void)presentLoginScene {
    // for overwrite
}

@end

BOOL MBOperationLoginRequired(void) {
    if (AppUser()) return NO;
    [AppNavigationController() _MBNavigationController_tryLogin];
    return YES;
}