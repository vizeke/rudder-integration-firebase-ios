//
//  RudderAdjustIntegration.h
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import <Foundation/Foundation.h>
#import "RudderIntegration.h"
#import "RudderClient.h"

@import FirebaseCore;
@import FirebaseAnalytics;

NS_ASSUME_NONNULL_BEGIN

@interface RudderFirebaseIntegration : NSObject<RudderIntegration>

@property NSArray* GOOGLE_RESERVED_KEYWORDS;
@property NSArray* RESERVED_PARAM_NAMES;

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RudderClient *)client withRudderConfig:(RudderConfig*) rudderConfig;

@end

NS_ASSUME_NONNULL_END
