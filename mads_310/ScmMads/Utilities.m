//
//  Utilities.m
//  ScmMads
//
//  Created by Yongmo on 8/17/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities {
    NSString *currentElement;
    NSFileManager *fileMgr;
}

@synthesize xmlParser;
@synthesize xmlContainer;

- (NSString *)getCurrentDateTime
{
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateString = [dataFormatter stringFromDate:tmpDate];
    return dateString;
}

#pragma - NSXMLParser Delegate methods

- (void)parseScmAdXmlFile: (NSData *)fileData
{
    xmlParser = [[NSXMLParser alloc] initWithData:fileData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
    xmlContainer = [[NSMutableDictionary alloc] init];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"[scm]: XMLParser Error: %@", [parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"object - %@, key - %@", string, currentElement);
    [xmlContainer setObject:string  forKey:currentElement];
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    currentElement = nil;
    fileMgr = [NSFileManager defaultManager];

    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scmAdPlist.plist"];
    
    if ([fileMgr fileExistsAtPath:filePath]) {
        [fileMgr removeItemAtPath:filePath error:nil];
    }
    
    [xmlContainer writeToFile:filePath atomically:YES];
    xmlContainer = nil;
    
}



@end
