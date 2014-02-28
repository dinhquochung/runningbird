//
//  PlayScene.m
//  runningbird
//
//  Created by Dinh Quoc Hung on 2/15/14.
//  Copyright Dinh Quoc Hung 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "PlayScene.h"
#import "IntroScene.h"
#import "GameOverScene.h"

// -----------------------------------------------------------------------
#pragma mark - PlayScene
// -----------------------------------------------------------------------

@implementation PlayScene
{
    CCSprite* _bird;
    CCSprite* cloud;
    CCSprite* chimney;
    
    int kScrollSpeed;
    
    int best;
    int current;
    
    CCPhysicsNode *_physicsWorld;
    
    CCActionRepeatForever *megaAction;
    CCActionSequence *actionTap;
    
    CCLabelTTF *currentCount;
    CCLabelTTF *bestCount;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (PlayScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    kScrollSpeed = 3;
    best = 0;
    current = 0;
    
    [[OALSimpleAudio sharedInstance] playEffect:@"background.mp3" loop:YES];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
    CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
    [self addChild:batch];
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    _screenSize = self.contentSize;
    
    _bg1 = [CCSprite spriteWithImageNamed:@"bg.png"];
    _bg1.position = CGPointMake(0, _screenSize.height * 0.5f);
    _bg1.anchorPoint = CGPointMake(0, 0.5f);
    [self addChild:_bg1];
    
    _bg2 = [CCSprite spriteWithImageNamed:@"bg.png"];
    _bg2.position = CGPointMake(_bg2.contentSize.width, _bg1.position.y);
    _bg2.anchorPoint = CGPointMake(0, 0.5f);
    [self addChild:_bg2];
    
    CCLabelTTF *bestLabel = [CCLabelTTF labelWithString:@"Best: " fontName:@"Chalkduster" fontSize:20.0f];
    bestLabel.positionType = CCPositionTypeNormalized;
    bestLabel.color = [CCColor whiteColor];
    bestLabel.position = ccp(0.85f, 0.95f); // Middle of screen
    [self addChild:bestLabel];
    
    bestCount = [CCLabelTTF labelWithString:@"0" fontName:@"Chalkduster" fontSize:20.0f];
    bestCount.positionType = CCPositionTypeNormalized;
    bestCount.color = [CCColor whiteColor];
    bestCount.position = ccp(0.93f, 0.95f); // Middle of screen
    [self addChild:bestCount];
    
    currentCount = [CCLabelTTF labelWithString:@"0" fontName:@"Chalkduster" fontSize:20.0f];
    currentCount.positionType = CCPositionTypeNormalized;
    currentCount.color = [CCColor whiteColor];
    currentCount.position = ccp(0.05f, 0.95f); // Middle of screen
    [self addChild:currentCount];
    
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    //_physicsWorld.debugDraw = YES;
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
    
    // Add a bird
    _bird = [CCSprite spriteWithImageNamed:@"player_1.png"];
    _bird.position  = ccp(self.contentSize.width/3, self.contentSize.height/2);
    _bird.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _bird.contentSize} cornerRadius:0]; // 1
    _bird.physicsBody.collisionGroup = @"playerGroup"; // 2
    _bird.physicsBody.collisionType  = @"playerCollision";
    [_physicsWorld addChild:_bird];
    
    CGPoint targetPositionUp = ccp(_screenSize.width/3, _screenSize.height/2 + 50);
    CGPoint targetPositionDown = ccp(_screenSize.width/3, _screenSize.height/2);
    
    CCAction *actionMoveUp = [CCActionMoveTo actionWithDuration:1.0f position:targetPositionUp];
    CCAction *actionMoveDown = [CCActionMoveTo actionWithDuration:1.0f position:targetPositionDown];

    megaAction = [CCActionRepeatForever actionWithAction:[CCActionSequence actionWithArray:@[actionMoveUp,actionMoveDown]]];
    [_bird runAction:megaAction];
    
//    
//    cloud = [CCSprite spriteWithImageNamed:@"cloud.png"];
//    cloud.position  = ccp(self.contentSize.width/3*2, self.contentSize.height/4*3);
//    [self addChild:cloud];
//    
//    chimney = [CCSprite spriteWithImageNamed:@"roof_1.png"];
//    chimney.position  = ccp(self.contentSize.width/3*2, self.contentSize.height/2);
//    [self addChild:chimney];

    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    [self schedule:@selector(addCloud:) interval:1.5];
    //[self schedule:@selector(addChimney:) interval:((arc4random() % 6) + 2.0)];
    [self schedule:@selector(addChimney:) interval:1];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Pr frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"object argument: %fnt", _bird.position.y);

    if (fabsf(_bird.position.y - 29) <= 0.001) {
        
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
                                   withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
        return;
    }
    
    [[megaAction innerAction] stop];
    [_bird stopAction:megaAction];
    
    [actionTap stop];
    [_bird stopAction:actionTap];
    
    CGPoint targetPositionUp = ccp(_screenSize.width/3, _bird.position.y + 70);
    CGPoint targetPositionDown = ccp(_screenSize.width/3, 29);
    
    CCAction *actionMoveUp = [CCActionMoveTo actionWithDuration:0.9f position:targetPositionUp];
    CCAction *actionMoveDown = [CCActionMoveTo actionWithDuration:1.7f position:targetPositionDown];
    actionTap = [CCActionSequence actionWithArray:@[actionMoveUp,actionMoveDown]];
    [_bird runAction:actionTap];
}

- (void)addChimney:(CCTime)dt {
    
    chimney = [CCSprite spriteWithImageNamed:@"roof_1.png"];
    // 1
    int minY = chimney.contentSize.height / 2;
    int maxY = self.contentSize.height - chimney.contentSize.height / 2;
    int rangeY = maxY - minY;
    int randomY = (arc4random() % rangeY) + minY;
    
    // 2
    chimney.position = CGPointMake(self.contentSize.width + chimney.contentSize.width/2, randomY);
    chimney.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, chimney.contentSize} cornerRadius:0]; // 1
    chimney.physicsBody.collisionGroup = @"dieGroup"; // 2
    chimney.physicsBody.collisionType  = @"dieCollision";
    [_physicsWorld addChild:chimney];
    
    // 3
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    // 4
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(-chimney.contentSize.width/2, randomY)];
    CCAction *actionRemove = [CCActionRemove action];
    [chimney runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    
}

- (void)addCloud:(CCTime)dt {
    
    cloud = [CCSprite spriteWithImageNamed:@"cloud.png"];
    // 1
    int minY = cloud.contentSize.height / 2;
    int maxY = self.contentSize.height - cloud.contentSize.height / 2;
    int rangeY = maxY - minY;
    int randomY = (arc4random() % rangeY) + minY;
    
    // 2
    cloud.position = CGPointMake(self.contentSize.width + cloud.contentSize.width/2, randomY);
    cloud.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, cloud.contentSize} cornerRadius:0]; // 1
    cloud.physicsBody.collisionGroup = @"foeGroup"; // 2
    cloud.physicsBody.collisionType  = @"foeCollision";
    [_physicsWorld addChild:cloud];
    
    // 3
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    // 4
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(-cloud.contentSize.width/2, randomY)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];

}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)player dieCollision:(CCNode *)die {
    
    [[OALSimpleAudio sharedInstance] playEffect:@"boom.wav"];
    
    [[megaAction innerAction] stop];
    [_bird stopAction:megaAction];
    
    [self unschedule:@selector(addChimney:)];
    [self unschedule:@selector(addCloud:)];
    
    CGPoint targetPositionDown = ccp(_screenSize.width/3, 29);
    CCAction *actionMoveDown = [CCActionMoveTo actionWithDuration:1.0f position:targetPositionDown];
    
    CCActionCallBlock *actionMoveDone = [CCActionCallBlock actionWithBlock:^{
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
                                   withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
        

    }];

    [_bird runAction:[CCActionSequence actionWithArray:@[actionMoveDown, actionMoveDone]]];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)player foeCollision:(CCNode *)foe {
    [[OALSimpleAudio sharedInstance] playEffect:@"oops.wav"];
    current = current + 1;
    [currentCount setString:[NSString stringWithFormat:@"%d", current]];
    [foe removeFromParent];
    return YES;
}

-(void) update:(CCTime)delta {
    
    CGPoint bg1Pos = _bg1.position;
	CGPoint bg2Pos = _bg2.position;
	bg1Pos.x -= kScrollSpeed;
	bg2Pos.x -= kScrollSpeed;
    
	// move scrolling background back from left to right end to achieve "endless" scrolling
	if (bg1Pos.x < -(_bg1.contentSize.width))
	{
		bg1Pos.x += _bg1.contentSize.width;
		bg2Pos.x += _bg2.contentSize.width;
	}
    
	// remove any inaccuracies by assigning only int values (this prevents floating point rounding errors accumulating over time)
	bg1Pos.x = (int)bg1Pos.x;
	bg2Pos.x = (int)bg2Pos.x;
	_bg1.position = bg1Pos;
	_bg2.position = bg2Pos;
    
}

// -----------------------------------------------------------------------
@end