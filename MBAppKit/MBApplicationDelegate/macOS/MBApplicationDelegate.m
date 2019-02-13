
#import "MBApplicationDelegate.h"

@interface MBApplicationDelegate ()
@property (nonatomic) NSHashTable *_MBApplicationDelegate_eventListeners;
@end

@implementation MBApplicationDelegate

#pragma mark - 通用事件监听

- (NSHashTable *)_MBApplicationDelegate_eventListeners {
    if (__MBApplicationDelegate_eventListeners) return __MBApplicationDelegate_eventListeners;
    __MBApplicationDelegate_eventListeners = [NSHashTable weakObjectsHashTable];
    return __MBApplicationDelegate_eventListeners;
}

- (void)addAppEventListener:(nullable id<NSApplicationDelegate>)listener {
    @synchronized(self) {
        [self._MBApplicationDelegate_eventListeners addObject:listener];
    }
}

- (void)removeAppEventListener:(nullable id<NSApplicationDelegate>)listener {
    @synchronized(self) {
        [self._MBApplicationDelegate_eventListeners removeObject:listener];
    }
}

#define _app_delegate_event_notice1(SELECTOR)\
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
    for (id<NSApplicationDelegate> listener in all) {\
        if (![listener respondsToSelector:@selector(SELECTOR:)]) continue;\
        [listener SELECTOR:application];\
    }\

#define _app_delegate_event_notice2(SELECTOR, PARAMETER1)\
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
    for (id<NSApplicationDelegate> listener in all) {\
        if (![listener respondsToSelector:@selector(application:SELECTOR:)]) continue;\
        [listener application:application SELECTOR:PARAMETER1];\
    }

#define _app_delegate_event_notice3(SELECTOR1, PARAMETER1, SELECTOR2, PARAMETER2)\
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
    for (id<NSApplicationDelegate> listener in all) {\
        if (![listener respondsToSelector:@selector(application:SELECTOR1:SELECTOR2:)]) continue;\
        [listener application:application SELECTOR1:PARAMETER1 SELECTOR2:PARAMETER2];\
    }

#define _app_delegate_event_method(SELECTOR) \
    - (void)SELECTOR:(NSApplication *)application {\
        _app_delegate_event_notice1(SELECTOR) }

#define _app_delegate_event_method2(SELECTOR) \
    - (void)application:(NSApplication *)application SELECTOR:(id)obj {\
        _app_delegate_event_notice2(SELECTOR, obj) }

_app_delegate_event_method2(openURLs)

_app_delegate_event_method2(didRegisterForRemoteNotificationsWithDeviceToken)
_app_delegate_event_method2(didFailToRegisterForRemoteNotificationsWithError)
_app_delegate_event_method2(didReceiveRemoteNotification)

_app_delegate_event_method2(willEncodeRestorableState)
_app_delegate_event_method2(didDecodeRestorableState)

- (BOOL)application:(NSApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];
    for (id<NSApplicationDelegate> ls in all) {
        if (![ls respondsToSelector:@selector(application:willContinueUserActivityWithType:)]) continue;
        if ([ls application:application willContinueUserActivityWithType:userActivityType]) return YES;
    }
    return NO;
}

- (void)application:(NSApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error {
    _app_delegate_event_notice3(didFailToContinueUserActivityWithType, userActivityType, error, error)
}
_app_delegate_event_method2(didUpdateUserActivity)

_app_delegate_event_method2(userDidAcceptCloudKitShareWithMetadata)

#define _app_delegate_event_notification_method(SELECTOR) \
    - (void)SELECTOR:(NSNotification *)notification {\
        NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
        for (id<NSApplicationDelegate> listener in all) {\
            if (![listener respondsToSelector:@selector(SELECTOR:)]) continue;\
            [listener SELECTOR:notification];\
        }\
    }

_app_delegate_event_notification_method(applicationWillHide)
_app_delegate_event_notification_method(applicationDidHide)
_app_delegate_event_notification_method(applicationWillUnhide)
_app_delegate_event_notification_method(applicationDidUnhide)
_app_delegate_event_notification_method(applicationWillBecomeActive)
_app_delegate_event_notification_method(applicationDidBecomeActive)
_app_delegate_event_notification_method(applicationWillResignActive)
_app_delegate_event_notification_method(applicationDidResignActive)
_app_delegate_event_notification_method(applicationWillUpdate)
_app_delegate_event_notification_method(applicationDidUpdate)
_app_delegate_event_notification_method(applicationWillTerminate)
_app_delegate_event_notification_method(applicationDidChangeScreenParameters)
_app_delegate_event_notification_method(applicationDidChangeOcclusionState)

@end
