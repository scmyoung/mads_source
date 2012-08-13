//
//  SecondCommercialsAd.h
//  SecondCommercialsAd
//
//  Created by Yongmo Liang on 11/4/11.
//  Copyright (c) 2011 SecondCommercials. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum BannerPosition {
    TOP = 0,
    BOTTOM
}BannerPosition;

@protocol SecondCommercialsAdDelegate <NSObject>
- (void)scmAdViewWillShow;
- (void)scmAdViewDidFinish;
- (void)scmAdBannerWillShow;
@end

@interface SecondCommercialsAd : UIViewController <NSXMLParserDelegate, UIAlertViewDelegate> {
    
    // scmAdView - A view container, it contains a banner and stamp views
    UIView *scmAdView;
    
    // delegate
    id <SecondCommercialsAdDelegate> scmAdDelegate;
    
    /************************************************************/
    
}

@property (nonatomic, retain) UIView *scmAdView;
@property (nonatomic, assign) id <SecondCommercialsAdDelegate> scmAdDelegate;




- (id)initWithPosition:(BannerPosition)position;
- (void) scmShowAdBannerView : (NSInteger)point;
- (void) scmHideAdBannerView;

- (void) scmClearScmAd;


@end
