
#import "MBGeneralListExchanging.h"
#import "MBGeneralItemExchanging.h"
#import "UIView+RFKit.h"

BOOL MBGeneralListItemPassValue(id destination, id value) {
    if (![value isKindOfClass:NSArray.class]) {
        return NO;
    }
    if ([destination respondsToSelector:@selector(setItems:)]) {
        [(id<MBGeneralListItemExchanging>)destination setItems:value];
        return YES;
    }
    return NO;
}

@implementation UITableViewCell (App)

+ (nullable id)itemFromSender:(nullable id)sender {
    if (![sender isKindOfClass:[UIView class]]) {
        return nil;
    }
    id<MBGeneralItemExchanging> cell = (id)[sender superviewOfClass:[self class]];
    if (![cell respondsToSelector:@selector(item)]) {
        return nil;
    }
    return [cell item];
}

@end

@implementation UICollectionViewCell (App)

+ (nullable id)itemFromSender:(nullable id)sender {
    if (![sender isKindOfClass:[UIView class]]) {
        return nil;
    }
    id<MBGeneralItemExchanging> cell = (id)[sender superviewOfClass:[self class]];
    if (![cell respondsToSelector:@selector(item)]) {
        return nil;
    }
    return [cell item];
}

@end
