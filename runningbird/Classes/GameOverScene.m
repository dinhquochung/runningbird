//
//  GameOverScene.m
//  runningbird
//
//  Created by Dinh Quoc Hung on 2/16/14.
//  Copyright (c) 2014 Dinh Quoc Hung. All rights reserved.
//

#import "GameOverScene.h"
#import "IntroScene.h"
#import "PlayScene.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation GameOverScene {
    
   CCButton *ShareLinkWithShareDialogButton;
}

+ (IntroScene *)scene
{
  	return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    // Hello world
    CCButton *playingButton = [CCButton buttonWithTitle:@"GAME OVER" fontName:@"Chalkduster" fontSize:36.0f];
    playingButton.positionType = CCPositionTypeNormalized;
    playingButton.color = [CCColor redColor];
    playingButton.position = ccp(0.5f, 0.5f); // Middle of screen
    [playingButton setTarget:self selector:@selector(onPlayingClicked:)];
    [self addChild:playingButton];
    
    ShareLinkWithShareDialogButton = [CCButton buttonWithTitle:@"SHARE" fontName:@"Chalkduster" fontSize:20.0f];
    ShareLinkWithShareDialogButton.positionType = CCPositionTypeNormalized;
    ShareLinkWithShareDialogButton.color = [CCColor whiteColor];
    ShareLinkWithShareDialogButton.position = ccp(0.5f, 0.3f); // Middle of screen
    [ShareLinkWithShareDialogButton setTarget:self selector:@selector(onFBSharingClicked:)];
    [ShareLinkWithShareDialogButton setVisible:YES];
    [self addChild:ShareLinkWithShareDialogButton];
	
    // done
	return self;
}

- (void)onFBSharingClicked:(id)sender
{
    // Check if the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    params.name = @"Sharing Score";
    params.caption = @"You got Score";
    params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
    params.description = @"GREAT!!!!";
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:params.caption
                                  description:params.description
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Score Sharing", @"name",
                                       @"You Got Great Score", @"caption",
                                       @"Please try this great game", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)onPlayingClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[PlayScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // If the user is logged in, they can post to Facebook using API calls, so we show the buttons
    [ShareLinkWithShareDialogButton visible];
}

@end
