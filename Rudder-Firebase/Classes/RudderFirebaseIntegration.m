//
//  RudderAdjustIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderFirebaseIntegration.h"
#import "RudderLogger.h"
#import "ECommerceEvents.h"

@implementation RudderFirebaseIntegration

#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(nonnull RudderClient *)client  withRudderConfig:(nonnull RudderConfig *)rudderConfig {
    self = [super init];
    if (self) {
        _GOOGLE_RESERVED_KEYWORDS = [[NSArray alloc] initWithObjects:@"age", @"gender", @"interest", nil];
        _RESERVED_PARAM_NAMES = [[NSArray alloc] initWithObjects:@"product_id", @"name", @"category", @"quantity", @"price", @"currency", @"value", @"order_id", @"tax", @"shipping", @"coupon", nil];
        [FIRApp configure];
    }
    return self;
}

- (void)dump:(RudderMessage *)message {
    if (message != nil) {
        [self processRudderEvent:message];
    }
}

- (void) processRudderEvent: (nonnull RudderMessage *) message {
    NSString *type = message.type;
    if (type != nil) {
        if ([type  isEqualToString: @"identify"]) {
            NSString *userId = message.userId;
            if (userId != nil && ![userId isEqualToString:@""]) {
                [RudderLogger logDebug:@"Setting userId to firebase"];
                [FIRAnalytics setUserID:userId];
            }
            NSDictionary *traits = message.context.traits;
            if (traits != nil) {
                for (NSString *key in [traits keyEnumerator]) {
                    if (![_GOOGLE_RESERVED_KEYWORDS containsObject:key]) {
                        [FIRAnalytics setUserPropertyString:traits[key] forName:key];
                    }
                }
            }
        } else if ([type isEqualToString:@"screen"]) {
            if (message.event != nil && ![message.event isEqualToString:@""]) {
                [FIRAnalytics setScreenName:message.event screenClass:nil];
            }
        } else if ([type isEqualToString:@"track"]) {
            NSString *eventName = message.event;
            NSDictionary *properties = message.properties;
            if (eventName != nil && ![eventName isEqualToString:@""]) {
                NSString *firebaseEvent = @"";
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                if ([eventName isEqualToString:ECommPaymentInfoEntered]) {
                    firebaseEvent = kFIREventAddPaymentInfo;
                } else if ([eventName isEqualToString:ECommProductAdded]) {
                    firebaseEvent = kFIREventAddToCart;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductAddedToWishList]) {
                    firebaseEvent = kFIREventAddToWishlist;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:@"Application Opened"]) {
                    firebaseEvent = kFIREventAppOpen;
                } else if ([eventName isEqualToString:ECommCheckoutStarted]) {
                    firebaseEvent = kFIREventBeginCheckout;
                    [self addOrderProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommOrderCompleted]) {
                    firebaseEvent = kFIREventEcommercePurchase;
                    [self addOrderProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommOrderRefunded]) {
                    firebaseEvent = kFIREventPurchaseRefund;
                    [self addOrderProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductsSearched]) {
                    firebaseEvent = kFIREventSearch;
                    [self addSearchProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductShared]) {
                    firebaseEvent = kFIREventShare;
                    [self addShareProperties:params properties:properties];
                    params[kFIRParameterContentType] = @"product";
                } else if ([eventName isEqualToString:ECommCartShared]) {
                    firebaseEvent = kFIREventShare;
                    [self addShareProperties:params properties:properties];
                    params[kFIRParameterContentType] = @"cart";
                } else if ([eventName isEqualToString:ECommProductViewed]) {
                    firebaseEvent = kFIREventViewItem;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductListViewed]) {
                    firebaseEvent = kFIREventViewItemList;
                    [self addProductListProperty:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductRemoved]) {
                    firebaseEvent = kFIREventRemoveFromCart;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommCheckoutStepViewed]) {
                    firebaseEvent = kFIREventCheckoutProgress;
                    [self addCheckoutProperties:params properties:properties];
                } else {
                    firebaseEvent = eventName;
                }
                if(![firebaseEvent isEqualToString:@""]) {
                    [self attachCustomProperties:params properties:properties];
                    [FIRAnalytics logEventWithName:firebaseEvent parameters:params];
                }
            }
        } else {
            [RudderLogger logWarn:@"Message type is not recognized"];
        }
    }
}

- (void) addCheckoutProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSNumber *step = properties[@"step"];
        if (step != nil) {
            [params setValue:step forKey:kFIRParameterCheckoutStep];
        }
    }
}

- (void) addProductListProperty: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *category = properties[@"category"];
        if (category != nil) {
            [params setValue:category forKey:kFIRParameterItemCategory];
        }
    }
}

- (void) addShareProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *cart_id = properties[@"cart_id"];
        NSString *product_id = properties[@"product_id"];
        if (cart_id != nil) {
            [params setValue:cart_id forKey:kFIRParameterItemID];
        } else if (product_id != nil) {
            [params setValue:product_id forKey:kFIRParameterItemID];
        }
        NSString *share_via = properties[@"share_via"];
        if (share_via != nil) {
            [params setValue:share_via forKey:kFIRParameterMethod];
        }
    }
}

- (void) addSearchProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *query = properties[@"query"];
        if (query != nil) {
            [params setValue:query forKey:kFIRParameterSearchTerm];
        }
    }
}

- (void) addOrderProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSNumber *value = properties[@"value"];
        if (value != nil) {
            [params setValue:value forKey:kFIRParameterValue];
        }
        NSString *currency = properties[@"currency"];
        if (currency != nil) {
            [params setValue:currency forKey:kFIRParameterCurrency];
        }
        NSString *order_id = properties[@"order_id"];
        if (order_id != nil) {
            [params setValue:order_id forKey:kFIRParameterTransactionID];
        }
        NSNumber *tax = properties[@"tax"];
        if (tax != nil) {
            [params setValue:tax forKey:kFIRParameterTax];
        }
        NSNumber *shipping = properties[@"shipping"];
        if (shipping != nil) {
            [params setValue:shipping forKey:kFIRParameterShipping];
        }
        NSString *coupon = properties[@"coupon"];
        if (coupon != nil) {
            [params setValue:coupon forKey:kFIRParameterCoupon];
        }
    }
}

- (void) addProductProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *product_id = properties[@"product_id"];
        if (product_id != nil) {
            [params setValue:product_id forKey:kFIRParameterItemID];
        }
        NSString *name = properties[@"name"];
        if (name != nil) {
            [params setValue:product_id forKey:kFIRParameterItemName];
        }
        NSString *category = properties[@"category"];
        if (category != nil) {
            [params setValue:category forKey:kFIRParameterItemCategory];
        }
        NSNumber *quantity = properties[@"quantity"];
        if (quantity != nil) {
            [params setValue:quantity forKey:kFIRParameterQuantity];
        }
        NSNumber *price = properties[@"price"];
        if (price != nil) {
            [params setValue:quantity forKey:kFIRParameterPrice];
        }
        NSString *currency = properties[@"currency"];
        if (currency != nil) {
            [params setValue:currency forKey:kFIRParameterCurrency];
        }
    }
}

- (void) attachCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if(properties != nil && params != nil) {
        for (NSString *key in [properties keyEnumerator]) {
            if (![_RESERVED_PARAM_NAMES containsObject:key]) {
                [params setValue:properties[key] forKey:key];
            }
        }
    }
}

- (void)reset {
    // Firebase doesn't support reset functionality
}

@end

