
#import "MBAPI.h"
#import "MBGeneralCallback.h"
#import <RFMessageManager/RFMessageManager+RFDisplay.h>
#import <RFMessageManager/RFNetworkActivityIndicatorMessage.h>

MBAPI *MBAPI_global_ = nil;

@interface MBAPI ()
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSDate *> *> *requestIntervalRecord;
@end

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
    RFAssert(ruleCount == prules.count, @"分组中有规则重名了");
    
    [self.defineManager setDefinesWithRulesInfo:prules];
}

#pragma mark - 请求管理

+ (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters viewController:(UIViewController *)viewController loadingMessage:(NSString *)message modal:(BOOL)modal success:(void (^)(AFHTTPRequestOperation *, id))success completion:(void (^)(AFHTTPRequestOperation *))completion {
    return [self requestWithName:APIName parameters:parameters viewController:viewController forceLoad:NO loadingMessage:message modal:modal success:success failure:nil completion:completion];
}

+ (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters viewController:(UIViewController *)viewController forceLoad:(BOOL)forceLoad loadingMessage:(NSString *)message modal:(BOOL)modal success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *))completion {
    RFAPIControl *cn = RFAPIControl.new;
    if (message) {
        cn.message = [RFNetworkActivityIndicatorMessage.alloc initWithIdentifier:APIName title:nil message:message status:RFNetworkActivityIndicatorStatusLoading];
        cn.message.modal = modal;
    }
    cn.identifier = APIName;
    cn.groupIdentifier = viewController.APIGroupIdentifier;
    cn.forceLoad = forceLoad;
    return [self.global requestWithName:APIName parameters:parameters controlInfo:cn success:success failure:failure completion:completion];
}

+ (void)backgroundRequestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters completion:(void (^)(BOOL success, id responseObject, NSError *error))completion {
    RFAPIControl *cn = RFAPIControl.new;
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

+ (void)cancelOperationsWithViewController:(UIViewController *)viewController {
    if (!viewController) return;
    [self.global cancelOperationsWithGroupIdentifier:viewController.APIGroupIdentifier];
}

#pragma mark - RequestInterval

- (NSMutableDictionary *)requestIntervalRecord {
    if (!_requestIntervalRecord) {
        _requestIntervalRecord = [NSMutableDictionary.alloc initWithCapacity:4];
    }
    return _requestIntervalRecord;
}

- (NSMutableDictionary<NSString *, NSDate *> *)requestIntervalRecordForVC:(UIViewController *)vc {
    return self.requestIntervalRecord[vc.APIGroupIdentifier];
}

- (void)enableRequestIntervalForViewController:(UIViewController *)viewController APIName:(NSString *)name {
    if (!viewController || !name) return;
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    if (!r) {
        r = [NSMutableDictionary.alloc initWithCapacity:2];
        self.requestIntervalRecord[viewController.APIGroupIdentifier] = r;
    }
    if (!r[name]) {
        r[name] = NSDate.distantPast;
    }
}

- (void)setRequestIntervalForViewController:(UIViewController *)viewController APIName:(NSString *)name {
    if (!viewController || !name) return;
    doutwork()
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    if (!r || !r[name]) return;
    r[name] = NSDate.date;
}

- (BOOL)shouldRequestForViewController:(UIViewController *)viewController minimalInterval:(NSTimeInterval)interval {
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    NSDate *now = NSDate.date;
    for (NSDate *d in r.objectEnumerator) {
        if (fabs([now timeIntervalSinceDate:d]) < interval) {
            return NO;
        }
    }
    NSArray *names = r.allKeys;
    // @TODO: 开放 RFAPI 对 control 的接口
    for (AFHTTPRequestOperation *op in [self operationsWithGroupIdentifier:viewController.APIGroupIdentifier]) {
        RFAPIControl *ac = op.userInfo[@"RFAPIOperationUIkControl"];
        if (!ac) continue;
        if ([names containsObject:ac.identifier]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldRequestForViewController:(id)viewController APIName:(NSString *)APIName minimalInterval:(NSTimeInterval)interval {
    if (!APIName) {
        return [self shouldRequestForViewController:viewController minimalInterval:interval];
    }
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    NSDate *now = NSDate.date;
    if (fabs([now timeIntervalSinceDate:r[APIName]]) < interval) {
        return NO;
    }
    return YES;
}

- (void)clearRequestIntervalForViewController:(UIViewController *)viewController {
    if (!viewController) return;
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    NSMutableDictionary<NSString *, NSDate *> *copy = r.mutableCopy;
    for (NSString *key in r) {
        copy[key] = NSDate.distantPast;
    }
    [r setDictionary:copy];
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
