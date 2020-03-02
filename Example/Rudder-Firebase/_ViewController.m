//
//  _ViewController.m
//  Rudder-Firebase
//
//  Created by arnabp92 on 02/11/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_ViewController.h"
#import <Rudder/Rudder.h>

@interface _ViewController ()

@end

@implementation _ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[RudderClient sharedInstance] track:@"daily_rewards_claim"];
    [[RudderClient sharedInstance] track:@"level_up"];
    [[RudderClient sharedInstance] track:@"revenue"];
    [[RudderClient sharedInstance] identify:@"developer_user_id" traits:@{@"foo": @"bar", @"foo1": @"bar1"}];
    [[RudderClient sharedInstance] track:@"test_event" properties:@{@"key":@"value", @"foo": @"bar"}];
    [[RudderClient sharedInstance] track:@"purchase" properties:@{@"total":@2.99, @"currency": @"USD"}];
    [[RudderClient sharedInstance] reset];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
