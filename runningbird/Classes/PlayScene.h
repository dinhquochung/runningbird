//
//  PlayScene.h
//  runningbird
//
//  Created by Dinh Quoc Hung on 2/15/14.
//  Copyright Dinh Quoc Hung 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */

@interface PlayScene : CCScene <CCPhysicsCollisionDelegate>
{
    CGSize _screenSize;

    CCSprite* _bg1;
    CCSprite* _bg2;
}

// -----------------------------------------------------------------------

+ (PlayScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end