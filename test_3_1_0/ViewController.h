//
//  ViewController.h
//  test_3_1_0
//
//  Created by Yongmo on 8/16/12.
//  Copyright (c) 2012 Yongmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ScmMads/ScmMads.h>

@interface ViewController : UIViewController


@property (nonatomic, strong) ScmMads *scmMads;
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (IBAction)show:(id)sender;
- (IBAction)hide:(id)sender;

@end
