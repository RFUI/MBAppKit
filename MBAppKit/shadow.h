/*!
 shadow
 
 Copyright © 2018 RFUI. All rights reserved.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 
 MBAppKit 套件是通用的，不能定义与业务直接关联的东西。
 但写一个通用的流程上的东西又难免需要引用业务模块，通过这个头文件来引入项目中的代码。
 其中的方法需要在项目中定义。
 */
#pragma once

#import <Foundation/Foundation.h>

#if defined(MBBuildConfiguration)
#   error "这个文件不应导出到项目"
#endif

#pragma mark - ShortCuts

@class MBEnvironment;
/// 状态依赖
MBEnvironment *__nullable AppEnv(void);

#pragma mark - debug
/**
 debug 方法应当随项目编译，但套件仍需要引用部分 debug 中的方法
 */

FOUNDATION_EXPORT BOOL RFAssertKindOfClass(id __nullable obj, Class __nonnull aClass);
FOUNDATION_EXPORT void DebugLog(BOOL fatal, NSString *_Nullable recordID, NSString *_Nonnull format, ...) NS_FORMAT_FUNCTION(3, 4);
