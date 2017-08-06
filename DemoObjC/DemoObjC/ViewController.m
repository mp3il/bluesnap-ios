//
//  ViewController.m
//  DemoObjc
//
//  Created by oz on 06/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

#import "ViewController.h"
@import BluesnapSDK;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Creating token");
    
    // Do any additional setup after loading the view, typically from a nib.
    BSToken*  token = [BlueSnapSDK createSandboxTestTokenOrNil];
    NSLog(@"Got token %@" , token.getTokenStr);
    
    
    NSLog(@"Finished");
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
