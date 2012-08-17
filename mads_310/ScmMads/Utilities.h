//
//  Utilities.h
//  ScmMads
//
//  Created by Yongmo on 8/17/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject <NSXMLParserDelegate>


@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableDictionary *xmlContainer;

- (NSString *)getCurrentDateTime;


@end
