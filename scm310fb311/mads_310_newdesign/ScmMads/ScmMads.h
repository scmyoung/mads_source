//
//  ScmMads.h
//  ScmMads
//
//  Created by jimmy on 8/9/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>

@protocol ScmMadsDelegate <NSObject>
- (void)scmMadsViewWillShow;
- (void)scmMadsViewDidFinish;
- (void)scmMadsBannerWillShow;
@end

@interface ScmMads : UIViewController<PKAddPassesViewControllerDelegate>


@property (strong,nonatomic) id<ScmMadsDelegate> scmMadsDelegate;

- (id) initScmMads;

- (void) showScmMads:(NSInteger)points;
- (void) hideScmMads;

@end
