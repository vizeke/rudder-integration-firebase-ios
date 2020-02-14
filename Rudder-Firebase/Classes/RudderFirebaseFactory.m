//
//  RudderAdjustFactory.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderFirebaseFactory.h"
#import "RudderFirebaseIntegration.h"

@implementation RudderFirebaseFactory

static RudderFirebaseFactory *sharedInstance;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (nonnull NSString *)key {
    return @"Firebase";
}

- (nonnull id<RudderIntegration>)initiate:(nonnull NSDictionary *)config client:(nonnull RudderClient *)client rudderConfig:(nonnull RudderConfig *)rudderConfig {
    return [[RudderFirebaseIntegration alloc] initWithConfig:config withAnalytics:client withRudderConfig:rudderConfig];
}

@end
