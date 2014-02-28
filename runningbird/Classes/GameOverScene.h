//
//  GameOverScene.h
//  runningbird
//
//  Created by Dinh Quoc Hung on 2/16/14.
//  Copyright (c) 2014 Dinh Quoc Hung. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <FacebookSDK/FacebookSDK.h>

@interface GameOverScene : CCScene <FBLoginViewDelegate>

+ (GameOverScene *)scene;
- (id)init;

@end
