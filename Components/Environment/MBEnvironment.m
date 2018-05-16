
#import "MBEnvironment.h"
#import <RFKit/NSArray+RFKit.h>

@interface MBEnvironmentObserver : NSObject
@property MBENVFlag flags;
@property dispatch_block_t handler;
@property (weak) id target;
@property SEL selector;
@property BOOL removeAfterCall;
@property BOOL hasCalledWhenMeet;
@end

static MBEnvironment *MBApplicationDefaultEnvironment;
static NSMutableArray<MBEnvironmentObserver *> *MBApplicationDefaultHandlers;

@interface MBEnvironment ()
@property MBENVFlag _MBEnvironment_flags;
@property NSMutableArray<MBEnvironmentObserver *> *_MBEnvironment_observers;
@property (nullable) NSMutableArray<MBEnvironmentObserver *> *_MBEnvironment_applicationHandlers;
@end

@implementation MBEnvironment

+ (void)setAsApplicationDefaultEnvironment:(MBEnvironment *)env {
    if (MBApplicationDefaultEnvironment != env) {
        if (MBApplicationDefaultEnvironment) {
            MBApplicationDefaultEnvironment._MBEnvironment_applicationHandlers = nil;
        }
        MBApplicationDefaultEnvironment = env;
        if (env) {
            env._MBEnvironment_applicationHandlers = MBApplicationDefaultHandlers;
            for (MBEnvironmentObserver *ob in MBApplicationDefaultHandlers) {
                ob.target = env;
            }
            [env _MBEnvironment_flagChange];
        }
    }
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    __MBEnvironment_observers = [NSMutableArray arrayWithCapacity:32];
    return self;
}

- (dispatch_queue_t)queue {
    @synchronized(self) {
        if (_queue) {
            return _queue;
        }
        _queue = dispatch_get_main_queue();
        return _queue;
    }
}

#pragma mark - Flag opration

- (BOOL)meetFlags:(MBENVFlag)flags {
    return ((self._MBEnvironment_flags & flags) == flags);
}

- (void)setFlagOn:(MBENVFlag)flag {
    MBENVFlag oldFlags = self._MBEnvironment_flags;
    if (oldFlags == (oldFlags | flag)) return;

    self._MBEnvironment_flags = (oldFlags | flag);
    [self _MBEnvironment_flagChange];
}

- (void)setFlagOff:(MBENVFlag)flag {
    MBENVFlag oldFlags = self._MBEnvironment_flags;
    if (oldFlags == (oldFlags & ~ flag)) return;

    self._MBEnvironment_flags = (oldFlags & ~ flag);
    [self _MBEnvironment_flagChange];
}

#pragma mark - Flag change

- (void)_MBEnvironment_flagChange {
    dispatch_async(self.queue, ^{
        if (self._MBEnvironment_applicationHandlers) {
            [self _MBEnvironment_handleChange:self._MBEnvironment_applicationHandlers];
        }
        [self _MBEnvironment_handleChange:self._MBEnvironment_observers];
    });
}

- (void)_MBEnvironment_handleChange:(NSMutableArray *)allObservers {
    @synchronized(self) {
        if (!allObservers.count) return;

        MBENVFlag flags = self._MBEnvironment_flags;
        NSMutableArray<MBEnvironmentObserver *> *meetObs = [allObservers rf_mapedArrayWithBlock:^id _Nullable(MBEnvironmentObserver *ob) {
            MBENVFlag obFlags = ob.flags;
            BOOL meet = (obFlags & flags) == obFlags;
            if (meet) {
                if (!ob.hasCalledWhenMeet) {
                    return ob;
                }
            }
            else {
                if (ob.hasCalledWhenMeet) {
                    ob.hasCalledWhenMeet = NO;
                }
            }
            return nil;
        }];

        for (MBEnvironmentObserver *ob in meetObs) {
            if (self._MBEnvironment_flags != flags) {
                break;
            }

            BOOL shouldRemove = ob.removeAfterCall;
            if (ob.handler) {
                ob.handler();
                ob.hasCalledWhenMeet = YES;
            }
            else if (ob.target) {
                [UIApplication.sharedApplication sendAction:ob.selector to:ob.target from:self forEvent:nil];
                ob.hasCalledWhenMeet = YES;
            }
            else {
                shouldRemove = YES;
            }

            if (shouldRemove) {
                [allObservers removeObject:ob];
            }
        }
    }
}

#pragma mark - Observer

- (void)waitFlags:(MBENVFlag)flags do:(dispatch_block_t)block timeout:(NSTimeInterval)timeout {
    if ([self meetFlags:flags]) {
        block();
    }
    else {
        MBEnvironmentObserver *ob = [MBEnvironmentObserver new];
        ob.flags = flags;
        ob.handler = block;
        ob.removeAfterCall = YES;
        [self._MBEnvironment_observers addObject:ob];
        if (timeout) {
            @weakify(self);
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
            dispatch_after(time, self.queue, ^{
                @strongify(self);
                [self._MBEnvironment_observers removeObject:ob];
            });
        }
    }
}

- (id)registerFlagsObserver:(MBENVFlag)flags handler:(dispatch_block_t)handler {
    NSParameterAssert(handler);
    MBEnvironmentObserver *ob = [MBEnvironmentObserver new];
    ob.flags = flags;
    ob.handler = handler;
    @synchronized(self) {
        [self._MBEnvironment_observers addObject:ob];
    }
    return ob;
}

- (void)removeFlagsObserver:(id)observer {
    if (observer) {
        [self._MBEnvironment_observers removeObject:observer];
    }
}

#pragma mark - Static Observe

+ (void)staticObserveFlag:(MBENVFlag)flags selector:(SEL)selector handleOnce:(BOOL)handleOnce {
    NSParameterAssert(selector);
    if (!MBApplicationDefaultHandlers) {
        MBApplicationDefaultHandlers = [NSMutableArray arrayWithCapacity:32];
    }
    MBEnvironmentObserver *ob = [MBEnvironmentObserver new];
    ob.flags = flags;
    ob.selector = selector;
    ob.removeAfterCall = handleOnce;
    [MBApplicationDefaultHandlers addObject:ob];
}

@end


@implementation MBEnvironmentObserver
@end
