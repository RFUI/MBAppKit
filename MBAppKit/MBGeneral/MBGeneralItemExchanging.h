/*!
 MBEntityExchanging
 
 Copyright © 2018 RFUI. All rights reserved.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import "RFRuntime.h"

/**
 标准视图间 model 交换协议
 */
@protocol MBGeneralItemExchanging <NSObject>
@required
@property (nonatomic, nullable, strong) id item;

@optional

/// 期望的 item 类型
- (nonnull Class)preferredItemClass;

@end


/**
 item 的可选协议
 */
@protocol MBItemExchanging <NSObject>
@optional
- (NSString *_Nullable)displayString;
@end
