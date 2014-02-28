//
//  IntroScene.m
//  runningbird
//
//  Created by Dinh Quoc Hung on 2/15/14.
//  Copyright Dinh Quoc Hung 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "PlayScene.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene {

    FBLoginView *loginView;

}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    // Hello world
    CCButton *playingButton = [CCButton buttonWithTitle:@"Play" fontName:@"Chalkduster" fontSize:36.0f];
    playingButton.positionType = CCPositionTypeNormalized;
    playingButton.color = [CCColor redColor];
    playingButton.position = ccp(0.5f, 0.5f); // Middle of screen
    [playingButton setTarget:self selector:@selector(onPlayingClicked:)];
    [self addChild:playingButton];
    
    loginView = [[FBLoginView alloc] init];
    loginView.delegate = self;
    loginView.readPermissions = @[@"basic_info", @"email", @"user_likes"];
    loginView.frame = CGRectOffset(loginView.frame, (self.contentSize.height - (loginView.frame.size.width / 2)), 5);
    [[[CCDirector sharedDirector] view] addSubview:loginView];
    
    _nameLabel = [CCLabelTTF labelWithString:@"" fontName:@"Chalkduster" fontSize:20.0f];
    _nameLabel.positionType = CCPositionTypeNormalized;
    _nameLabel.color = [CCColor whiteColor];
    _nameLabel.position = ccp(0.25f, 0.95f); // Middle of screen
    [self addChild:_nameLabel];
    
    _statusLabel = [CCLabelTTF labelWithString:@"" fontName:@"Chalkduster" fontSize:20.0f];
    _statusLabel.positionType = CCPositionTypeNormalized;
    _statusLabel.color = [CCColor whiteColor];
    _statusLabel.position = ccp(0.35f, 0.35f); // Middle of screen
    [self addChild:_statusLabel];

    
	    // done
	return self;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
     CCLOG(@"loginViewFetchedUserInfo");
    self.profilePictureView.profileID = user.id;
     [_nameLabel setString:user.name];
    
    self.profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:user.id pictureCropping:FBProfilePictureCroppingSquare];
    CGSize s = self.contentSize;
    CGRect f = self.profilePictureView.frame;
    // Center the profile picture in the screen.
    f.origin = ccp(self.contentSize.height/2, self.contentSize.width/2);
    self.profilePictureView.frame = f;
    [[CCDirector sharedDirector].view addSubview:self.profilePictureView];
    
    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
   
    [self.statusLabel setString:@"You're logged in as"];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  
    self.profilePictureView.profileID = nil;
     [self.nameLabel setString:@""];
     [self.statusLabel setString:@"You're not logged in!"];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onPlayingClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[PlayScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------

- (void)onExitTransitionDidStart {
    [loginView removeFromSuperview];
}
@end
