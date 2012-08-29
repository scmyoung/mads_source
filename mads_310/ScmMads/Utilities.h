//
//  Utilities.h
//  ScmMads
//
//  Created by Yongmo on 8/17/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject <NSXMLParserDelegate>


@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableDictionary *xmlContainer;
@property (nonatomic, strong) UIAlertView *alert_dv_fb;
@property (nonatomic, strong) UIAlertView *alert_dv_tw;

- (NSString *)getCurrentDateTime;
- (void)parseScmAdXmlFile: (NSData *)fileData;


@end
