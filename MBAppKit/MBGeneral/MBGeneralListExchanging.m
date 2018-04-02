
#import "MBGeneralListExchanging.h"
#import "MBGeneralItemExchanging.h"
#import "UIView+RFKit.h"

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
