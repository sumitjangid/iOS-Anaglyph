//
//  ViewController.m
//  Anaglyph
//
//  Created by Sumit Jangid on 11/14/15.
//  Copyright © 2015 Sumit Jangid. All rights reserved.
//

#import "ViewController.h"
#import "BlendMode.h"
#import "SingletonCIContext.h"

@interface ViewController (){
    
    CIContext *context;
}

@end

@implementation ViewController
@synthesize showResult;
int count = 0;
@synthesize image1;
@synthesize image2;
@synthesize imagePreview, captureImage, stillImageOutput, blendMode;

- (void)viewDidLoad {
    // Assign Singleton Context
    context = [SingletonCIContext context];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FrontCamera = NO;
    
    captureImage.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    //Opens the Camera
    [self initCamera];
    
}

//Switch between Front Camera and Back Camera
- (IBAction)switchCamera:(id)sender {
    
    if ([sender selectedSegmentIndex] == 0) {
        
        NSLog(@"switch to front camera");
        FrontCamera = YES;
        [self initCamera];
    } else {
        FrontCamera = NO;
        [self initCamera];
    }
}

//Open the camera and add audio and video connection into it
- (void)initCamera {
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [imagePreview bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
            if ([device position] == AVCaptureDevicePositionFront) {
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    if (!FrontCamera) {
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        [session addInput:input];
    } else {
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        [session addInput:input];
        
    }
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    [session startRunning];
    
    //Alert Info to take Left Image(First Image)
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                   message:@"Take Left Image!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)snapImage:(id)sender {
    
    [self capImage];
}

- (void) capImage {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
        
    }];
    
}

//Change the color of the First Image(Left Image) to Cyan Color
-(UIImage*)changeColorToCyan:(UIImage*)temp {
    
    @autoreleasepool {
        
        CIImage *image = [CIImage imageWithCGImage:temp.CGImage];
        
        CIFilter *colorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
        
        [colorMatrixFilter setDefaults];
        [colorMatrixFilter setValue:image forKey:kCIInputImageKey];
        [colorMatrixFilter setValue:[CIVector vectorWithX:0.00 Y:1.00 Z:1.00 W:1.00] forKey:@"inputRVector"];
        
        image = colorMatrixFilter.outputImage;
        
        CGImageRef cgImage = [context createCGImage:image fromRect:[image extent]];
        
        UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        return uiImage;
        
    }
}

//Change the color of the Second Image(Right Image) to Red Color
-(UIImage*)changeColorToRed:(UIImage*)temp {
    
    @autoreleasepool {
        
        CIImage *image = [CIImage imageWithCGImage:temp.CGImage];
        
        CIFilter *filter = [CIFilter filterWithName:@"CITemperatureAndTint" keysAndValues:@"inputImage",image,@"inputNeutral",[CIVector vectorWithX:6500 Y:765], @"inputTargetNeutral",[CIVector vectorWithX:4500 Y:255],nil];
        
        image = filter.outputImage;
        
        //                CIFilter *colorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
        //                [colorMatrixFilter setDefaults];
        //                [colorMatrixFilter setValue:image forKey:kCIInputImageKey];
        //                [colorMatrixFilter setValue:[CIVector vectorWithX:1.00 Y:0.00 Z:0.00 W:1.00] forKey:@"inputRVector"];
        //
        //                image = colorMatrixFilter.outputImage;
        //
        CGImageRef cgImage = [context createCGImage:image fromRect:[image extent]];
        UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        return uiImage;
        
    }
}

- (UIImage *)setCompositeImage
{
    UIImage *compositeImage = [BlendMode blendImage:image2 blendImage:image1
                                          blendMode:kCGBlendModeScreen blendAlpha:1.0f
                                               rect:[imagePreview bounds]];
    return compositeImage;
}

//Combining First Image(Left Image) with Second Image(Right Image)
- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage withAlpha:(CGFloat)alpha {
    
    @autoreleasepool {
        
        //BlendModeScreen
        
        UIImage *resultingImage = nil;
        UIGraphicsBeginImageContext(firstImage.size);
        
        CGRect rect = CGRectMake(0, 0, firstImage.size.width, firstImage.size.height);
        
        [firstImage drawInRect:rect];
        [secondImage drawInRect:rect blendMode:kCGBlendModeScreen alpha:0.40f];
        
        resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultingImage;
        
    }
}

//Process Left Image and Right Image, Combining them and Saving into Photos Album
- (void) processImage:(UIImage *)image {
    
    count++;
    if(count == 1){
        
        image1 = [self changeColorToRed:image];
        
        //         image1 = [self changeColorToCyan:image];
        
        //Alert Info to take Right Image(Second Image)
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                       message:@"Left Image Taken! Take Right Image"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    else if(count == 2) {
        
        image2 = [self changeColorToCyan:image];
        
        //        image2 = [self changeColorToRed:image];
        
        image2 = [self imageByCombiningImage:image1 withImage:image2 withAlpha:1.00f];
        
        UIImageWriteToSavedPhotosAlbum(image2,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        image1 = nil;
        image2 = nil;
        image = nil;
        
        // Alert Info for Image Saved into Photos Album
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                       message:@"Image Saved to Photos Album!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        count = 0;
    }
    
}

//Release the Image which is saved to Album
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    
    NSLog(@"Releasing image");
    image = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return YES;
}

@end
