//
//  ViewController.h
//  Anaglyph
//
//  Created by Sumit Jangid on 11/14/15.
//  Copyright © 2015 Sumit Jangid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface ViewController : UIViewController {
    
    BOOL FrontCamera;
    
}

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (weak, nonatomic) IBOutlet UIView *imagePreview;

@property (weak, nonatomic) IBOutlet UIImageView *captureImage;

@property (weak, nonatomic) UIImageView *showResult;
//image1 is Left Image (First Image)
@property UIImage* image1;
//image2 is Right Image (Second Image)
@property UIImage* image2;

//Action for Snap Image
- (IBAction)snapImage:(id)sender;

//Action for Switching camera (Front and Back)
- (IBAction)switchCamera:(id)sender;

@property(nonatomic) CGBlendMode blendMode;

@end

