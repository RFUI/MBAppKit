
#import "MBApplicationFont.h"
#import "NSObject+MBAppKit.h"

static UIFont *_MBApplicationDefaultFont;

static BOOL MBIsSystemFontWithFamilyName(NSString *familyName) {
    return [familyName isEqualToString:@".Helvetica Neue Interface"]
    || [familyName isEqualToString:@".SF UI Text"];
}

@implementation UIFont (MBApplicationFont)

+ (void)setApplicaitonDefaultFontWithFontName:(NSString *)name {
    UIFont *f = [UIFont fontWithName:name size:[UIFont systemFontSize]];
    if (!f) {
        NSLog(@"Cannot set application default font, could not find font with name: %@", name);
        return;
    }

    _MBApplicationDefaultFont = f;

    [UILabel.appearance setDefaultApplicationFontWithFontName:name];
    [UITextField.appearance setDefaultApplicationFontWithFontName:name];
    [UITextView.appearance setDefaultApplicationFontWithFontName:name];
}

+ (UIFont *)MBApplicationFontOfSize:(CGFloat)fontSize {
    if (_MBApplicationDefaultFont) {
        return [_MBApplicationDefaultFont fontWithSize:fontSize];
    }
    return [self systemFontOfSize:fontSize];
}

@end

@implementation UILabel (MBApplicationFont)

- (void)setDefaultApplicationFontWithFontName:(NSString *)name {
    if (!MBIsSystemFontWithFamilyName(self.font.familyName)) return;
    if (NSFoundationVersionNumber > 1100
        && NSFoundationVersionNumber < 1141
        && [self.className hasSuffix:@"UITableViewHeaderFooterViewLabel"]) {
        // iOS 8.0.x 上不设置 table view 默认 header 里的样式
    }
    else {
        // UIPickerView 里不设置，不含 date picker
        if ([NSStringFromClass(self.superview.class) hasPrefix:@"UIPicker"]) {
            return;
        }
        self.font = [UIFont fontWithName:name size:self.font.pointSize];
    }
}

@end

@implementation UITextField (MBApplicationFont)

- (void)setDefaultApplicationFontWithFontName:(NSString *)name {
    if (!MBIsSystemFontWithFamilyName(self.font.familyName)) return;
    self.font = [UIFont fontWithName:name size:self.font.pointSize];
}

@end

@implementation UITextView (MBApplicationFont)

- (void)setDefaultApplicationFontWithFontName:(NSString *)name {
    if (!MBIsSystemFontWithFamilyName(self.font.familyName)) return;
    self.font = [UIFont fontWithName:name size:self.font.pointSize];
}

@end
