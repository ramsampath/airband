//
//  NowPlayingController.h
//  airband
//
//  Created by Scot Shinderman on 8/27/08.
//  Copyright 2008 Elliptic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NowPlayingController : UIViewController {
	IBOutlet UIImageView  *albumcover_;
	IBOutlet UISlider     *volume_;
	IBOutlet UIButton     *play_;
	IBOutlet UITextView   *trackinfo_;
    IBOutlet UIAlertView  *alert;
    IBOutlet UIProgressView *progbar;
}

-(IBAction) setvolume:(id)sender;
-(IBAction) pause:(id)sender;
-(IBAction) play:(id)sender;
-(IBAction) next:(id)sender;
-(IBAction) prev:(id)sender;

-(IBAction) random:(id)sender;
-(IBAction) taptap:(id)sender;

@end
