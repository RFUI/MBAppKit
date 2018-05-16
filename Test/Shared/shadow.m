/**
 shadow.h 中的定义需要在项目中实现
 */

#import <RFKit/RFRuntime.h>
#import <MBApplicationDelegate.h>
#import <MBEnvironment.h>

int MBENVFlagNaigationLoaded = 0;

id __nullable AppDelegate(void) {
    static MBApplicationDelegate *s;
    if (!s) {
        s = MBApplicationDelegate.new;
    }
    return s;
}

id __nullable AppEnv(void) {
    static MBEnvironment *s;
    if (!s) {
        s = MBEnvironment.new;
    }
    return s;
}

BOOL RFAssertKindOfClass(id obj, Class aClass) {
    if (obj
        && ![obj isKindOfClass:aClass]) {
        RFAssert(false, @"Expected kind of %@, actual is %@", aClass, [obj class]);
        return NO;
    }
    return YES;
}

void DebugLog(BOOL fatal, NSString *_Nullable recordID, NSString *_Nonnull format, ...) {
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
    if (fatal) {
        @try {
            @throw [NSException exceptionWithName:@"pause" reason:@"debug" userInfo:nil];
        }
        @catch (NSException *exception) { }
    }
}
