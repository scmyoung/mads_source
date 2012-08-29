//
//  ViewController.m
//  test_3_1_0
//
//  Created by Yongmo on 8/16/12.
//  Copyright (c) 2012 Yongmo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize scmMads;
@synthesize textField;

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)show:(id)sender
{
    [scmMads showScmMads:[textField.text intValue]];
}

- (IBAction)hide:(id)sender
{
    [scmMads hideScmMads];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    
    scmMads = [[ScmMads alloc] initScmMads];
    [self.view addSubview:scmMads.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end




