//
//  ScmMads.h
//  ScmMads
//
//  Created by jimmy on 8/9/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScmMadsDelegate <NSObject>



@end

@interface ScmMads : UIViewController


@property(strong,nonatomic)UIImageView *scmView;
@property(strong,nonatomic)id<ScmMadsDelegate>ScmMadsDelegate;

-(id)initScmMads;

-(void)showScmMads:(NSInteger)points;
-(void)hidenScmMads;

@end
