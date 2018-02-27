
#import "MBGeneralSegue.h"
#import "MBGeneralItemExchanging.h"
#import "MBGeneralListExchanging.h"

id _Nullable MBGeneralSegueItem(UIStoryboardSegue *_Nonnull segue, id _Nullable sender, Class _Nullable cellClass, id _Nullable viewController) {
    id item;
    if ([sender respondsToSelector:@selector(item)]) {
        item = [(id<MBGeneralItemExchanging>)sender item];
    }
    else if (cellClass) {
        if ([cellClass respondsToSelector:@selector(itemFromSender:)]) {
            item = [cellClass itemFromSender:sender];
        }
    }

    if (!item) {
        if ([viewController respondsToSelector:@selector(item)]) {
            item = [(id<MBGeneralItemExchanging>)viewController item];
        }
    }
    return item;
}
