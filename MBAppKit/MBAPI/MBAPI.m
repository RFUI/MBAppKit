
#import "MBAPI.h"
#import "MBGeneralCallback.h"
#import "RFMessageManager+RFDisplay.h"
#import "RFNetworkActivityIndicatorMessage.h"

MBAPI *MBAPI_global_ = nil;

@implementation MBAPI

+ (MBAPI *)global {
    @synchronized(self) {
        return MBAPI_global_;
    }
}

+ (void)setGlobal:(__kindof MBAPI *)global {
    @synchronized(self) {
        MBAPI_global_ = global;
    }
}

- (void)onInit {
    [super onInit];
    self.maxConcurrentOperationCount = 5;
    self.responseProcessingQueue = dispatch_queue_create("API.Processing", DISPATCH_QUEUE_SERIAL);
}

- (void)setupAPIDefineWithPlistPath:(NSString *)path {
    NSDictionary *rules = [[NSDictionary alloc] initWithContentsOfFile:path];
    RFAssert(rules, @"Cannot get api define rules at path: %@", path);
    NSMutableDictionary<NSString *, NSDictionary *> *prules = [NSMutableDictionary dictionary];
    __block NSInteger ruleCount = 0;
    [rules enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key hasPrefix:@"@"]) {
            [prules addEntriesFromDictionary:obj];
            ruleCount += obj.count;
        }
        else {
            prules[key] = obj;
            ruleCount++;
        }
    }];
    _dout_debug(@"载入 %ld 个接口定义", ruleCount);
    RFAssert(ruleCount == prules.count, @"有规则重名了");
    
    [self.defineManager setDefinesWithRulesInfo:prules];
}

#pragma mark - 请求管理

+ (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters viewController:(UIViewController *)viewController loadingMessage:(NSString *)message modal:(BOOL)modal success:(void (^)(AFHTTPRequestOperation *, id))success completion:(void (^)(AFHTTPRequestOperation *))completion {
    return [self requestWithName:APIName parameters:parameters viewController:viewController forceLoad:NO loadingMessage:message modal:modal success:success failure:nil completion:completion];
}

+ (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters viewController:(UIViewController *)viewController forceLoad:(BOOL)forceLoad loadingMessage:(NSString *)message modal:(BOOL)modal success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *))completion {
    RFAPIControl *cn = [[RFAPIControl alloc] init];
    if (message) {
        cn.message = [[RFNetworkActivityIndicatorMessage alloc] initWithIdentifier:APIName title:nil message:message status:RFNetworkActivityIndicatorStatusLoading];
        cn.message.modal = modal;
    }
    cn.identifier = APIName;
    cn.groupIdentifier = NSStringFromClass(viewController.class);
    cn.forceLoad = forceLoad;
    return [self.global requestWithName:APIName parameters:parameters controlInfo:cn success:success failure:failure completion:completion];
}

+ (void)backgroundRequestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters completion:(void (^)(BOOL success, id responseObject, NSError *error))completion {
    RFAPIControl *cn = [[RFAPIControl alloc] init];
    cn.identifier = APIName;
    cn.backgroundTask = YES;
    __block MBGeneralCallback safeCallback = MBSafeCallback(completion);
    [self.global requestWithName:APIName parameters:parameters controlInfo:cn success:^(AFHTTPRequestOperation * _Nullable operation, id  _Nullable responseObject) {
        safeCallback(YES, responseObject, nil);
        safeCallback = nil;
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        safeCallback(NO, nil, error);
        safeCallback = nil;
    } completion:^(AFHTTPRequestOperation * _Nullable operation) {
        if (safeCallback) {
            safeCallback(NO, nil, nil);
        }
    }];
}

+ (void)cancelOperationsWithViewController:(id)viewController {
    if (!viewController) return;
    [self.global cancelOperationsWithGroupIdentifier:NSStringFromClass([viewController class])];
}

#pragma mark - 状态提醒

+ (void)showSuccessStatus:(NSString *)message {
    [self.global.networkActivityIndicatorManager showWithTitle:nil message:message status:RFNetworkActivityIndicatorStatusSuccess modal:NO priority:RFMessageDisplayPriorityHigh autoHideAfterTimeInterval:0 identifier:nil groupIdentifier:nil userInfo:nil];
}

+ (void)showErrorStatus:(NSString *)message {
    [self.global.networkActivityIndicatorManager showWithTitle:nil message:message status:RFNetworkActivityIndicatorStatusFail modal:NO priority:RFMessageDisplayPriorityHigh autoHideAfterTimeInterval:0 identifier:nil groupIdentifier:nil userInfo:nil];
}

+ (void)alertError:(NSError *)error title:(NSString *)title {
    [self.global.networkActivityIndicatorManager alertError:error title:title];
}

@end

#import <objc/runtime.h>

static char UIViewController_APIControl_CateogryProperty;

@implementation UIViewController (MBAPIControl)

- (NSString *)APIGroupIdentifier {
    id value = objc_getAssociatedObject(self, &UIViewController_APIControl_CateogryProperty);
    if (value) return value;
    return NSStringFromClass(self.class);
}

- (void)setAPIGroupIdentifier:(NSString *)APIGroupIdentifier {
    objc_setAssociatedObject(self, &UIViewController_APIControl_CateogryProperty, APIGroupIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)manageAPIGroupIdentifierManually {
    return NO;
}

@end
