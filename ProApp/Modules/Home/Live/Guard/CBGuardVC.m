//
//  CBGuardVC.m
//  ProApp
//
//  Created by 陈冰 on 2018/5/2.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBGuardVC.h"

@interface CBGuardVC ()

@end

@implementation CBGuardVC

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
