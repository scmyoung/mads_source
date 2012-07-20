/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBLoginDialog_Scm.h"
#import "FBRequest_Scm.h"

@protocol FBSessionDelegate_Scm;

/**
 * Main Facebook interface for interacting with the Facebook developer API.
 * Provides methods to log in and log out a user, make requests using the REST
 * and Graph APIs, and start user interface interactions (such as
 * pop-ups promoting for credentials, permissions, stream posts, etc.)
 */
@interface Facebook_Scm : NSObject<FBLoginDialogDelegate_Scm>{
  NSString* _accessToken;
  NSDate* _expirationDate;
  id<FBSessionDelegate_Scm> _sessionDelegate;
  FBRequest_Scm* _request;
  FBDialog_Scm* _loginDialog;
  FBDialog_Scm* _fbDialog;
  NSString* _appId;
  NSString* _urlSchemeSuffix;
  NSArray* _permissions;
}

@property(nonatomic, copy) NSString* accessToken;
@property(nonatomic, copy) NSDate* expirationDate;
@property(nonatomic, assign) id<FBSessionDelegate_Scm> sessionDelegate;
@property(nonatomic, copy) NSString* urlSchemeSuffix;

- (id)initWithAppId:(NSString *)appId
        andDelegate:(id<FBSessionDelegate_Scm>)delegate;

- (id)initWithAppId:(NSString *)appId
    urlSchemeSuffix:(NSString *)urlSchemeSuffix
        andDelegate:(id<FBSessionDelegate_Scm>)delegate;

- (void)authorize:(NSArray *)permissions;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)logout:(id<FBSessionDelegate_Scm>)delegate;

- (FBRequest_Scm*)requestWithParams:(NSMutableDictionary *)params
                    andDelegate:(id <FBRequestDelegate_Scm>)delegate;

- (FBRequest_Scm*)requestWithMethodName:(NSString *)methodName
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <FBRequestDelegate_Scm>)delegate;

- (FBRequest_Scm*)requestWithGraphPath:(NSString *)graphPath
                       andDelegate:(id <FBRequestDelegate_Scm>)delegate;

- (FBRequest_Scm*)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                       andDelegate:(id <FBRequestDelegate_Scm>)delegate;

- (FBRequest_Scm*)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                     andHttpMethod:(NSString *)httpMethod
                       andDelegate:(id <FBRequestDelegate_Scm>)delegate;

- (void)dialog:(NSString *)action
   andDelegate:(id<FBDialogDelegate_Scm>)delegate;

- (void)dialog:(NSString *)action
     andParams:(NSMutableDictionary *)params
   andDelegate:(id <FBDialogDelegate_Scm>)delegate;

- (BOOL)isSessionValid;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol FBSessionDelegate_Scm <NSObject>

@optional

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout;

@end
