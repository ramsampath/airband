//
//  NowPlayingController.m
//  airband
//
//  Created by Scot Shinderman on 8/27/08.
//  Copyright 2008 Elliptic. All rights reserved.
//


#import "NowPlayingController.h"
//#import <MediaPlayer/MediaPlayer.h>
#import "PlaylistTracksController.h"

#import "appdata.h"

@implementation UINavigationBar (UINavigationBarCategory)

-(void)setBackgroundImage:(UIImage*)image
{
	if(image == NULL){ //might be called with NULL argument
		return;
	}
	UIImageView *aTabBarBackground = [[UIImageView alloc]initWithImage:image];
	aTabBarBackground.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
	[self addSubview:aTabBarBackground];
	[self sendSubviewToBack:aTabBarBackground];
	[aTabBarBackground release];
}
@end


@implementation VolumeKnob

@synthesize volumeview_;
@synthesize volume_;

- (void)initialize
{	
    volumeview_                   = [[UIView alloc] initWithFrame:CGRectMake( 20, 330, 60, 60 )];
    //UIImageView *vkbg             = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"volume_knob.png"]];
    //vkbg.frame                    = CGRectMake( 5, 5, 55, 55 );
    
    volumebutton_ = [[UIButton buttonWithType:UIButtonTypeCustom]  initWithFrame:CGRectMake( 5, 5, 55, 55 )];    
	UIButton *button = volumebutton_;
    image_ = [[UIImage imageNamed:@"volume_knob.png"] retain];
    
    [volumeview_ addSubview:button];
    //[vkbg release];
    
	[button setImage:image_ forState:UIControlStateNormal];
	//[button setImage:nil forState:UIControlStateNormal];
	// set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
	[button addTarget:self action:@selector(volButtonTapped:event:) 
	 forControlEvents:UIControlEventTouchDown];
    
	[button addTarget:self action:@selector(volButtonDrag:event:) 
	 forControlEvents:UIControlEventTouchDragInside];
    
	//button.backgroundColor = [UIColor clearColor];
    
    center_.x   = 27.5;
    center_.y   = 27.5;
    radius_     = 22;
    starttheta_ = M_PI/4;

    volumeknobview_               = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"volume_indicator.png"]];
    float theta = starttheta_;
    [self setKnobPosition:theta];
    [volumeview_ addSubview:volumeknobview_];
    
    UIImageView *vplus            = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"volume_plus.png"]];
    vplus.frame                   = CGRectMake( 60, 55, 6, 6 );
    [volumeview_ addSubview:vplus];
    [vplus release];
    
    UIImageView *vmin             = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"volume_minus.png"]];
    vmin.frame                    = CGRectMake( 0, 58, 6, 2 );
    [volumeview_ addSubview:vmin];
    [vmin release];
}


-(void) setKnobPosition:(float) theta
{
    float xpos = radius_ * cos( theta );
    float ypos = radius_ * sin( theta );
    
    //volumeknobview_.frame  = CGRectMake( 10.5, center_.y + 10, 10, 10 );
    volumeknobview_.frame = CGRectMake( xpos + center_.x, ypos + center_.y, 10, 10 );
    
}


-(void) setVolume:(float) theta
{
    float value = (theta);
    
    if( value < 0 ) value = -value;
    else if( value > M_PI ) value -= M_PI;
    value /= (2*M_PI);
    value = 1 - value;
    
    printf( "Value: %f %f\n", value, theta );
    [[AppData get] setvolume:value];
}


- (void)volButtonDrag:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];	
	
	// [note] -- doing the calc in the parent coord system
	CGPoint currentTouchPosition = [touch locationInView:volumebutton_.superview];
	//float cx=image_.size.width/2.0;
	//float cy=image_.size.height/2.0;
	float cx = volumebutton_.frame.origin.x + volumebutton_.frame.size.width/2;
	float cy = volumebutton_.frame.origin.y + volumebutton_.frame.size.height/2;
	
	float theta1 = atan2( -(dragStart_.y-cy), dragStart_.x-cx );
	//float theta2 = atan2( -(currentTouchPosition.y-cy), currentTouchPosition.x-cx );
    
    float theta  = -theta1 ;
	// append the transform
	//volume_.transform = CGAffineTransformRotate( volume_.transform, theta1 - theta2 );
    
    [self setKnobPosition:theta];
	dragStart_ = currentTouchPosition;

    [self setVolume:theta];
    
    return;

}


- (void)volButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];	
	CGPoint currentTouchPosition = [touch locationInView:volumebutton_.superview];
	dragStart_ = currentTouchPosition;
}


@end 
// end --- volume knob


@implementation NowPlayingController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}

	return self;
}

-(id)init 
{
	if (self = [super init]) {
		self.hidesBottomBarWhenPushed = TRUE;
	}

	return self;
}



/*
 Implement loadView if you want to create a view hierarchy programmatically
 */

#pragma mark
#pragma mark UISlider (Custom)
#pragma mark
- (void)create_Custom_UISlider:(CGRect)frame
{
	volume_ = [[UISlider alloc] initWithFrame:frame];
	[volume_ addTarget:self action:@selector(setvolume:) forControlEvents:UIControlEventValueChanged];

	// in case the parent view draws with a custom color or gradient, use a transparent color
	volume_.backgroundColor = [UIColor clearColor];	

	[volume_ setThumbImage: [UIImage imageNamed:@"slider_ball_bw.png"] forState:UIControlStateNormal];

	volume_.minimumValue               = 0.0;
	volume_.maximumValue               = 1.0;
	volume_.continuous                 = YES;
	volume_.value                      = 1.0;
	volume_.alpha                      = 1.000;
	volume_.autoresizingMask           = UIViewAutoresizingFlexibleRightMargin | 
                                         UIViewAutoresizingFlexibleBottomMargin;
	volume_.clearsContextBeforeDrawing = YES;
	volume_.clipsToBounds              = YES;
	
	
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"leftslide.png"]
								stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage *stetchRightTrack = [[UIImage imageNamed:@"rightslide.png"]
								 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	//    [customSlider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
    [volume_ setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [volume_ setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	[volume_ setMinimumValueImage:[UIImage imageNamed:@"SpeakerSoft.tif"]];
	[volume_ setMaximumValueImage:[UIImage imageNamed:@"SpeakerLoud.tif"]];
		
}



-(void) setupnavigationitems:(UINavigationItem *) ni 
                      navBar:(UINavigationBar *) navBar
                      datadict:(NSDictionary *)dict
{
    UIImage *backimage    = [UIImage imageNamed:@"back_arrow.png"];
    UIBarButtonItem *b    = [UIBarButtonItem alloc];
    b.style               = UIBarButtonItemStyleBordered;
    b.image               = backimage;
    ni.backBarButtonItem  = b;
    [b release];
    
    UIImage *infoimage    = [UIImage imageNamed:@"track_info.png"];
    b                     = [UIBarButtonItem alloc];
    b.style               = UIBarButtonItemStyleBordered;
    b.image               = infoimage;
    [self.navigationItem setRightBarButtonItem:b];
    [b release];
    
    toolbartop_ = [[UIToolbar alloc] initWithFrame:CGRectMake( 0.0, 0.0, 320.0, 44.0)];
	toolbartop_.opaque                 = NO;
    toolbartop_.barStyle               = UIBarStyleBlackTranslucent;
    toolbartop_.backgroundColor        = [UIColor clearColor];

      

    //[navBar addSubview:toolbartop_];
    self.navigationItem.titleView = toolbartop_;
    self.navigationItem.titleView.frame = CGRectMake(30, 0, 280, 44);
    
    if( 1 ) {
        dict_ = dict;
		
		// view loaded, queue up tracklist.
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newlistReady:) 
													 name:@"trackListReady"
												   object:nil];	
		
		NSString *req = [dict_ objectForKey:@"albumId"];
	
		AppData *app = [AppData get];		
		[app getTrackListAsync:req];				
	}
}

- (void) viewDidDisappear
{
    [toolbar_ removeFromSuperview];
}


- (void)loadView 
{
	
	UIView *mainview          = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 436.0)];
	mainview.frame            = CGRectMake(0.0, 0.0, 320.0, 436.0);
	mainview.alpha            = 1.000;
	mainview.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | 
                                UIViewAutoresizingFlexibleBottomMargin;
	mainview.backgroundColor  = [UIColor colorWithRed:0.114 green:0.110 blue:0.090 alpha:1.000];
	mainview.clearsContextBeforeDrawing = YES;
	mainview.clipsToBounds              = NO;
	mainview.contentMode                = UIViewContentModeScaleToFill;
	mainview.hidden                     = NO;
	mainview.multipleTouchEnabled       = NO;
	mainview.opaque                     = YES;
	mainview.tag                        = 0;
	mainview.userInteractionEnabled     = YES;
    mainview.backgroundColor            = [UIColor 
                                           colorWithPatternImage:[UIImage 
                                           imageNamed:@"now_playing_background.png"]];

	//UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,640)];
	//UIImage *grad = [UIImage imageNamed:@"gradientBackground.png"];
	//image.image = grad;
	
    UIImage *stetchLeftTrack  = [[UIImage imageNamed:@"leftslide.png"]
								stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage *stetchLeftTrack2 = [[UIImage imageNamed:@"yellowslide.png"]
								stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage *stetchRightTrack = [[UIImage imageNamed:@"rightslide.png"]
								 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
	progbar_ = [[UISlider alloc] initWithFrame:CGRectMake( 18.0, 305.0, 284.0, 8.0 )];
    [progbar_ setThumbImage:nil forState:UIControlStateNormal];
    
    [progbar_ setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [progbar_ setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    progbar_.alpha                      = 1.0;
	progbar_.clearsContextBeforeDrawing = YES;
	progbar_.clipsToBounds              = NO;
	progbar_.contentMode                = UIViewContentModeScaleToFill;
	progbar_.multipleTouchEnabled       = YES;
	progbar_.opaque                     = YES;
	progbar_.tag                        = 0;
	progbar_.userInteractionEnabled     = NO;
    progbar_.minimumValue               = 0.0;
    progbar_.maximumValue               = 1.0;
	progbar_.value                      = 0.000;

    progbar2_ = [[UISlider alloc] initWithFrame:CGRectMake( 18.0, 305.0, 284.0, 8.0 )];
    [progbar2_ setThumbImage:nil forState:UIControlStateNormal];

    [progbar2_ setMinimumTrackImage:stetchLeftTrack2 forState:UIControlStateNormal];
    [progbar2_ setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    progbar2_.alpha                      = 0.5;
    progbar2_.backgroundColor            = [UIColor clearColor];
	progbar2_.clearsContextBeforeDrawing = YES;
	progbar2_.clipsToBounds              = NO;
	progbar2_.contentMode                = UIViewContentModeScaleToFill;
	progbar2_.multipleTouchEnabled       = YES;
	progbar2_.opaque                     = YES;
	progbar2_.tag                        = 0;
	progbar2_.userInteractionEnabled     = NO;
    progbar2_.minimumValue               = 0.0;
    progbar2_.maximumValue               = 1.0;
	progbar2_.value                      = 0.000;	
	
	CGRect volframe = CGRectMake( 81.0, 305.0, 147.0, 23.0 );
	[self create_Custom_UISlider:volframe];
 	    
    UIImageView *btbg             = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bottom_toolbar_background.png"]];
    btbg.frame                    = CGRectMake(0, 300, 320, 120);
    [mainview addSubview:btbg];
    [btbg release];

    volumeknob_ = [VolumeKnob alloc];
    [volumeknob_ initialize];
    [mainview addSubview:volumeknob_.volumeview_];

    trackinfo_                    = [[UIView alloc] initWithFrame:CGRectMake( 140.0, 310.0, 170.0, 140.0 )];
    trackinfo_.backgroundColor    = [UIColor clearColor];
    
    alabel_                        =  [[UILabel alloc] 
                                      initWithFrame:CGRectMake(0 , 30 , 320 , 10)]; 
    alabel_.text                   = [dict_ objectForKey:@"artistName"];
    alabel_.font                   = [UIFont fontWithName:@"Arial" size:12.0];
    alabel_.textAlignment          = UITextAlignmentLeft;
    alabel_.backgroundColor        = [UIColor clearColor];
    alabel_.textColor              = [UIColor grayColor];
    [trackinfo_ addSubview: alabel_];
    
    allabel_               =  [[UILabel alloc] 
                                       initWithFrame:CGRectMake(0 , 50 , 320 , 10)]; 
    allabel_.text                   = [dict_ objectForKey:@"albumTitle"];
    allabel_.font = [UIFont fontWithName:@"Arial" size:12.0];
    allabel_.textAlignment          = UITextAlignmentLeft;
    allabel_.backgroundColor        = [UIColor clearColor];
    allabel_.textColor              = [UIColor whiteColor];
    [trackinfo_ addSubview: allabel_];
    
    tlabel_                       =  [[UILabel alloc] 
                                      initWithFrame:CGRectMake(0 , 70 , 320 , 15)]; 
    tlabel_.text                   = [dict_ objectForKey:@"trackTitle"];
    tlabel_.font                   = [UIFont fontWithName:@"Arial" size:12.0];
    tlabel_.textAlignment          = UITextAlignmentLeft;
    tlabel_.backgroundColor        = [UIColor clearColor];
    tlabel_.textColor              = [UIColor grayColor];
    [trackinfo_ addSubview: tlabel_];
		
	toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 382.0, 320.0, 44.0)];
	//toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 300.0, 320.0, 100.0)];
	toolbar_.alpha = 1.000;
	//toolbar_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	//toolbar_.barStyle = UIBarStyleBlackTranslucent;

    toolbar_.barStyle                   = UIBarStyleBlackTranslucent;
	toolbar_.clearsContextBeforeDrawing = NO;
	toolbar_.clipsToBounds          = NO;
	toolbar_.contentMode            = UIViewContentModeBottom;
	toolbar_.hidden                 = NO;
	toolbar_.multipleTouchEnabled   = NO;
	toolbar_.opaque                 = NO;
	toolbar_.tag                    = 0;
	toolbar_.userInteractionEnabled = YES;
	toolbar_.backgroundColor = [UIColor clearColor];
    

    back_ = [UIButton alloc];
    back_.enabled = YES;
	back_.tag     = 0;

	albumcover_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 300.0)];
	albumcover_.alpha                      = 1.000;
	//albumcover_.autoresizingMask           = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	albumcover_.clearsContextBeforeDrawing = NO;
	albumcover_.clipsToBounds              = NO;
	//albumcover_.contentMode                = UIViewContentModeScaleAspectFill;
	albumcover_.hidden                     = NO;
	albumcover_.image                      = nil;
	albumcover_.multipleTouchEnabled       = NO;
	albumcover_.opaque                     = NO;
	albumcover_.tag                        = 0;
	albumcover_.userInteractionEnabled     = NO;
    
    /*
    nav_ = [[UINavigationBar alloc] 
           initWithFrame: CGRectMake( 0.0f, 0.0f, 320.0f, 55.0f )];
    [nav_ setBarStyle: 0];
    [nav_ setBarStyle:UIBarStyleBlackOpaque];
    UIImage *backimage = [UIImage imageNamed:@"back_arrow.png"];
    //nav_.backItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
    //                                  initWithTitle:@"Back"];
    [nav_ setDelegate: self];    
	*/
    pause_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause 
														   target:self action:@selector(pause:)];
	pause_.enabled = YES;
	pause_.style   = UIBarButtonItemStylePlain;
	pause_.tag     = 0;
	pause_.width   = 0.000;
    
    flexbeg_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                             target:nil action:nil];
	flexbeg_.enabled = YES;
	flexbeg_.style   = UIBarButtonItemStylePlain;
	flexbeg_.tag     = 0;
	flexbeg_.width   = 0.000;
	
	prev_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind 
														  target:self	action:@selector(prev:)];
	prev_.enabled = YES;
	prev_.style   = UIBarButtonItemStylePlain;
	prev_.tag     = 0;
	prev_.width   = 0.000;
	
	fixedprev_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                                               target:nil action:nil];
	fixedprev_.enabled = YES;
	fixedprev_.style   = UIBarButtonItemStylePlain;
	fixedprev_.tag     = 0;
	fixedprev_.width   = 20.000;
	
	stop_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
														  target:self action:@selector(stop:)];
	stop_.enabled = YES;
	stop_.style   = UIBarButtonItemStylePlain;
	stop_.tag     = 0;
	stop_.width   = 0.000;
	
	pause_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause 
														   target:self action:@selector(pause:)];
	pause_.enabled = YES;
	pause_.style   = UIBarButtonItemStylePlain;
	pause_.tag     = 0;
	pause_.width   = 0.000;
	
	fixedpause_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                target:nil action:nil];
	fixedpause_.enabled = YES;
	fixedpause_.style   = UIBarButtonItemStylePlain;
	fixedpause_.tag     = 0;
	fixedpause_.width   = 20.000;
	
	play_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
														  target:self action:@selector(play:)];
	play_.enabled = YES;
	play_.style   = UIBarButtonItemStylePlain;
	play_.tag     = 0;
	play_.width   = 0.000;
    
	
	fixedplay_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedplay_.enabled = YES;
	fixedplay_.style   = UIBarButtonItemStylePlain;
	fixedplay_.tag     = 0;
	fixedplay_.width   = 20.000;
	
	next_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward 
														  target:self action:@selector(next:)];
	next_.enabled = YES;
	next_.style   = UIBarButtonItemStylePlain;
	next_.tag     = 0;
	next_.width   = 0.000;
    
	flexend_         = [[UIBarButtonItem alloc] 
                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                        target:nil action:nil];
	flexend_.enabled = YES;
	flexend_.style   = UIBarButtonItemStylePlain;
	flexend_.tag     = 0;
	flexend_.width   = 0.000;
    
	busyimg_ = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, 100, 100)];
	busyimg_.image = [UIImage imageNamed:@"busySpinner.png"];
	busyimg_.opaque  = NO;
	busyimg_.alpha = 0;
	busyimg_.hidden = NO;
	
    AppData *app = [AppData get];
	[volume_ setValue:[app lastVolume_]];
	
    if( [app isrunning] ) {
		[toolbartop_ setItems:[NSArray arrayWithObjects: flexbeg_, prev_, fixedprev_, 
                               pause_,  fixedplay_, next_, flexend_, nil]]; 
	}
	else {
		[toolbartop_ setItems:[NSArray arrayWithObjects:flexbeg_, prev_, fixedprev_, 
                               play_,  fixedplay_, next_, flexend_, nil]];
	}
	//[mainview addSubview:image];
	
	//[mainview addSubview:toolbar_];
	[mainview addSubview:albumcover_];
	[mainview addSubview:progbar_];
	[mainview addSubview:progbar2_];
	[mainview addSubview:trackinfo_];
	[mainview addSubview:busyimg_];

    self.view = mainview;	
}


- (void)artworkReady:(NSObject*)notification
{
	AppData *app = [AppData get];
	UIImage *img = app.artwork_;
	if( img ) {
		albumcover_.image = img;
	} else {
		albumcover_.image = [UIImage imageNamed:@"airband.png"];
	}
	

    
	//[img drawInRect: CGRectMake(0.0f, 0.0f, 100.0f, 60.0f)]; // Draw in a custom rect.

	//UIImageView *imageView = [ [ UIImageView alloc ] initWithImage: albumcover_.image];
	//imageView.frame = CGRectMake(20.0, 55.0, 280.0, 176.0);
	//[self.view addSubview: imageView]; // Draw the image in self.view.

	tlabel_.text  = app.currentTrackTitle_;
    alabel_.text  = app.currentArtist_;
    allabel_.text = app.currentAlbum_;
}



- (void) newlistReady:(id)object
{			
	AppData *app = [AppData get];
	int num = [app.trackList_ count];
	if (!num) {
		printf( "tracklist is empty\n" );
		return;
	}
    
    
    [app setCurrentTrackIndex_:0];
    NSDictionary *d = [app.trackList_ objectAtIndex:0];
    [app playTrack:d];
}






- (void)viewDidLoad 
{
	AppData *app = [AppData get];

	[volume_ setValue:[app lastVolume_]];
	

   	// setup timer.
	if( 1 )
	{
		[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)0.5 
										 target:self 
									   selector:@selector(myTimerFireMethod:)
									   userInfo:NULL repeats:YES ];
	}	
}





/*
  [TODO] -- 
		flip the displayed view from the main view to the flipside(song list) view and vice-versa.
 */

- (void) toggleView 
{
	/*
	if (flipsideViewController == nil) {
		[self loadFlipsideViewController];
	}
	
	UIView *mainView = mainViewController.view;
	UIView *flipsideView = flipsideViewController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if ([mainView superview] != nil) {
		[flipsideViewController viewWillAppear:YES];
		[mainViewController viewWillDisappear:YES];
		[mainView removeFromSuperview];
        [infoButton removeFromSuperview];
		[self.view addSubview:flipsideView];
		[self.view insertSubview:flipsideNavigationBar aboveSubview:flipsideView];
		[mainViewController viewDidDisappear:YES];
		[flipsideViewController viewDidAppear:YES];
		
	} else {
		[mainViewController viewWillAppear:YES];
		[flipsideViewController viewWillDisappear:YES];
		[flipsideView removeFromSuperview];
		[flipsideNavigationBar removeFromSuperview];
		[self.view addSubview:mainView];
		[self.view insertSubview:infoButton aboveSubview:mainViewController.view];
		[flipsideViewController viewDidDisappear:YES];
		[mainViewController viewDidAppear:YES];
	}
	[UIView commitAnimations];
	 */
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([self.view superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) 
																			forView:self.view cache:YES];
	
	
	[UIView commitAnimations];	
}




- (void)nextTrack
{
    AppData *app = [AppData get];
    
    int index = [app currentTrackIndex_];
    if( ++index >= ([app.trackList_ count]) ) 
        index = 0;
    
    [app setCurrentTrackIndex_:index];
    NSDictionary *d = [app.trackList_ objectAtIndex:index];
    [app playTrack:d];
}

- (void)prevTrack
{
    AppData *app = [AppData get];
    
    int index = [app currentTrackIndex_];
    if( --index <  0) 
        index = [app.trackList_ count] - 1;
    
    [app setCurrentTrackIndex_:index];
    NSDictionary *d = [app.trackList_ objectAtIndex:index];
    [app playTrack:d];
}


- (void)myTimerFireMethod:(NSTimer*)theTimer
{
	AppData *app = [AppData get];

   	if( [app isrunning] ) {
		float cur = [app percent];
        float len = [app tracklength];

        if( cur >= len ) {
			[progbar_ setValue:0.0 animated:YES];
            //[progbar_ setProgress:0.0];
			[self nextTrack];
            //[app stop];
        }
		else {
			float per = cur/len;
			[progbar_ setValue:per animated:YES];
			//[progbar_ setProgress:per];
		}
	
		float approxBitRateMult = 4.0;
		float a = approxBitRateMult * [app trackFileSize] / app.currentTrackFileSize_;
		//albumcover_.alpha = a;
		//[progbar2_ setProgress:a];
        progbar2_.value = a;
		/*
		if(a<1)
		{
			[UIView beginAnimations:@"thump" context:nil];
			[UIView setAnimationDuration:0.5];
			//busyimg_.alpha = a;
			//busyimg_.transform = CGAffineTransformRotate( busyimg_.transform, a );			
			albumcover_.transform = CGAffineTransformRotate( albumcover_.transform, a );
			[UIView setAnimationRepeatAutoreverses:YES];			
			[UIView commitAnimations];	
		}
		*/
		
		//printf( "loaded: %f/%f\n", [app trackFileSize], app.currentTrackFileSize_ );
	}
	
	
    /*
	if( 0 ){
		[UIView beginAnimations:@"thump" context:nil];
		[UIView setAnimationDuration:2.9];	
		self.transform = CGAffineTransformMakeRotation(.5-drand48());
		self.alpha = 1-.1*drand48();
		[UIView setAnimationRepeatAutoreverses:YES];			
		[UIView commitAnimations];	
	}
     */
}


- (void) titleAvailable:(NSNotification*)notification
{
	NSDictionary *d     = notification.userInfo;
	NSString *title     = [d objectForKey:@"trackTitle"];
	NSString *artist    = [d objectForKey:@"artistName"];
	NSString *album     = [d objectForKey:@"albumTitle"];

	tlabel_.text  = title;
    alabel_.text  = artist;
    allabel_.text = album;
}



- (void)viewDidAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(artworkReady:) 
												 name:@"artworkReady" 
											   object:nil];	

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(titleAvailable:) 
												 name:@"titleAvailable" 
											   object:nil];	
	[self artworkReady:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction) setvolume:(id)sender
{	
	[[AppData get] setvolume:[volume_ value]];
}


-(IBAction) random:(id)sender
{
	AppData *app = [AppData get];
	NSArray* fullList = app.fullArtistList_;
	int index = drand48() * [fullList count];
	
	NSDictionary *d = [fullList objectAtIndex:index];
	//trackinfo_.text = [d objectForKey:@"albumTitle"];
	
	[app play:d];
}
	

-(IBAction) taptap:(id)sender
{
}

-(IBAction) play:(id)sender
{
	AppData *app = [AppData get];

	if( paused_ ) {
		[app resume];
		[toolbartop_ setItems:[NSArray arrayWithObjects:flexbeg_, prev_, fixedprev_,
							pause_,  fixedplay_, next_, flexend_, nil]];
	}
    else {
		int index = [app currentTrackIndex_];
		NSDictionary *d = [app.trackList_ objectAtIndex:index];
		[app playTrack:d];
	}
}

-(IBAction) next:(id)sender
{
    [self nextTrack];
}

-(IBAction) prev:(id)sender
{
    [self prevTrack];
}


-(IBAction) pause:(id)sender
{
	paused_ = true;
	
	[toolbartop_ setItems:[NSArray arrayWithObjects:flexbeg_, prev_, fixedprev_,
						play_,  fixedplay_, next_, flexend_, nil]];
	[[AppData get] pause];
	//[[AppData get] stop];
}

-(IBAction) stop:(id)sender
{
	paused_ = false;
	[[AppData get] stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
    printf ("dealloc\n");
	[super dealloc];
}



/**
 UIActionSheet
 
- (void)loadFlipsideViewController {
	PreferencesViewController *viewController = [[PreferencesViewController alloc] initWithNibName:@"PreferencesView" bundle:nil];
	self.preferencesViewController = viewController;
	preferencesViewController.rootViewController = self;
	[viewController release];
}


- (IBAction)toggleView:(id)sender {	
	// This method is called when the info or Done button is pressed.
	// It flips the displayed view from the main view to the flipside view and vice-versa.
	
	if (preferencesViewController == nil) {
		[self loadFlipsideViewController];
	}
	
	UIView *mainView = metronomeViewController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight) forView:self.view cache:YES];
	
	UIView *flipsideView = preferencesViewController.view;
	if ([mainView superview] != nil) {
		[mainView removeFromSuperview];
		[self.view addSubview:flipsideView];
	} else {
		[flipsideView removeFromSuperview];
		[self.view addSubview:mainView];
	}
	[UIView commitAnimations];
}

**/


@end
