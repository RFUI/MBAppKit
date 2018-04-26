/*!
 UIFont+MBApplicationFont
 
 Copyright © 2018 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <UIKit/UIKit.h>

@interface UIFont (MBApplicationFont)

/**
 设置全局 label 的字体
 
 @param name 字体的 PostScript name
 */
+ (void)setApplicaitonDefaultFontWithFontName:(NSString *)name;

/**
 
 */
+ (UIFont *)MBApplicationFontOfSize:(CGFloat)fontSize;

@end


@interface UILabel (MBApplicationFont)

- (void)setDefaultApplicationFontWithFontName:(NSString *)name UI_APPEARANCE_SELECTOR;

@end

@interface UITextField (MBApplicationFont)

- (void)setDefaultApplicationFontWithFontName:(NSString *)name UI_APPEARANCE_SELECTOR;

@end

@interface UITextView (MBApplicationFont)

- (void)setDefaultApplicationFontWithFontName:(NSString *)name UI_APPEARANCE_SELECTOR;

@end
