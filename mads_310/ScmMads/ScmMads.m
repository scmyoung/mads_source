//
//  ScmMads.m
//  ScmMads
//
//  Created by jimmy on 8/9/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import "ScmMads.h"

@interface ScmMads ()
{
    UIImageView *snsView;
    
    UIButton *bannerButton;
    UIButton *closeXButton;
    UIButton *closeArrowButton;
    
    UIButton *twtButton;
    UIButton *fbButton;
    
    
}

@end

@implementation ScmMads

@synthesize ScmMadsDelegate;
@synthesize scmView;

-(id)initScmMads
{
    self=[super init];
    
    scmView = [[UIImageView alloc]init];
    snsView = [[UIImageView alloc]init];
    
    bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeXButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    twtButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self createStampView];
    return self;
}

-(void)showScmMads:(NSInteger)points
{
    
    [UIImageView beginAnimations:@"bannerButton" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    scmView.frame = CGRectMake(0, -480, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)hidenScmMads
{
    [UIImageView beginAnimations:@"hideBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    scmView.frame = CGRectMake(0, -550, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)createStampView
{
    
    scmView.frame = CGRectMake(0, -550, 320, 550);
    [scmView setImage:[UIImage imageNamed:@"stamp1.png"]];
    [scmView setUserInteractionEnabled:YES];
    
    bannerButton.frame = CGRectMake(0, 480, 320, 550);
    closeArrowButton.frame = CGRectMake(82, 432, 156, 48);
    closeXButton.frame = CGRectMake(270, 0, 50, 53);
    
    [closeArrowButton setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    [closeXButton setImage:[UIImage imageNamed:@"xmark.png"] forState:UIControlStateNormal];

    [bannerButton addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeArrowButton addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXButton addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    
    [scmView addSubview:bannerButton];
    [scmView addSubview:closeArrowButton];
    [scmView addSubview:closeXButton];
    
}
-(void)showStamp
{
    [UIImageView beginAnimations:@"showStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    
    scmView.frame = CGRectMake(0, 0, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)hideStamp
{
    [UIImageView beginAnimations:@"hideBanner" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    
    scmView.frame = CGRectMake(0, -550, 320, 550);
    
    [UIImageView commitAnimations];
}




@end
