#import "PhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView 
{
	CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
	    
    // Yes, I know I'm a caveman for doing all this by hand
	GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:mainScreenFrame];
	primaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat height = (mainScreenFrame.size.width * 4 / 3);
    CGFloat y = (mainScreenFrame.size.height - height) / 2;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, mainScreenFrame.size.width, height)];
    imageView.hidden = YES;
    [primaryView addSubview:imageView];

    
    filterSettingsSlider = [[UISlider alloc] initWithFrame:CGRectMake(25.0, mainScreenFrame.size.height - 50.0, mainScreenFrame.size.width - 50.0, 40.0)];
    [filterSettingsSlider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
	filterSettingsSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    filterSettingsSlider.minimumValue = 0.0;
    filterSettingsSlider.maximumValue = 3.0;
    filterSettingsSlider.value = 1.0;
    
    [primaryView addSubview:filterSettingsSlider];
    
    photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    photoCaptureButton.frame = CGRectMake(round(mainScreenFrame.size.width / 2.0 - 150.0 / 2.0), mainScreenFrame.size.height - 90.0, 150.0, 40.0);
    [photoCaptureButton setTitle:@"Capture Photo" forState:UIControlStateNormal];
	photoCaptureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [photoCaptureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [primaryView addSubview:photoCaptureButton];
    
    resumeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    resumeButton.frame = CGRectMake(0, mainScreenFrame.size.height - 90.0, 100, 40);
    [resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    resumeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [resumeButton addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
    [resumeButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [primaryView addSubview:resumeButton];
    
	self.view = primaryView;	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    stillCamera = [[GPUImageStillCamera alloc] init];
//    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    filter = [[GPUImageGammaFilter alloc] init];
    filter = [[GPUImageSketchFilter alloc] init];
//    filter = [[GPUImageUnsharpMaskFilter alloc] init];
//    [(GPUImageSketchFilter *)filter setTexelHeight:(1.0 / 1024.0)];
//    [(GPUImageSketchFilter *)filter setTexelWidth:(1.0 / 768.0)];
//    filter = [[GPUImageSmoothToonFilter alloc] init];
//    filter = [[GPUImageSepiaFilter alloc] init];
//    filter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.5, 0.5, 0.5, 0.5)];
//    secondFilter = [[GPUImageSepiaFilter alloc] init];
//    terminalFilter = [[GPUImageSepiaFilter alloc] init];
//    [filter addTarget:secondFilter];
//    [secondFilter addTarget:terminalFilter];
    
//	[filter prepareForImageCapture];
//	[terminalFilter prepareForImageCapture];
    
//    [stillCamera addTarget:filter];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
//    [filter addTarget:filterView];
//    [filter addTarget:filterView];
    [stillCamera addTarget:filterView];
//    [terminalFilter addTarget:filterView];
    
//    [stillCamera.inputCamera lockForConfiguration:nil];
//    [stillCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
//    [stillCamera.inputCamera unlockForConfiguration];
    
    [stillCamera startCameraCapture];
    
//    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
//    memoryPressurePicture1 = [[GPUImagePicture alloc] initWithImage:inputImage];
//
//    memoryPressurePicture2 = [[GPUImagePicture alloc] initWithImage:inputImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updateSliderValue:(id)sender
{
//    [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:[(UISlider *)sender value]];
//    [(GPUImageGammaFilter *)filter setGamma:[(UISlider *)sender value]];
}

- (IBAction)takePhoto:(id)sender;
{
    [photoCaptureButton setEnabled:NO];

    [stillCamera capturePhotoAsSampleBufferWithCompletionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        NSLog(@"============================== captured sample time : %f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(imageSampleBuffer)));
        
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageSampleBuffer);
        CGSize sizeOfPhoto = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
        NSLog(@"APP sampleBuffer size = %f, %f", sizeOfPhoto.width, sizeOfPhoto.height);
        
        CIImage* ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgimage = [context createCGImage:ciImage
                                           fromRect:CGRectMake(0, 0,
                                                               CVPixelBufferGetWidth(pixelBuffer),
                                                               CVPixelBufferGetHeight(pixelBuffer))];
        
        UIImage *processedImage = [UIImage imageWithCGImage:cgimage scale:1.0f orientation:UIImageOrientationRight];
        

        imageView.image = processedImage;
        
        runOnMainQueueWithoutDeadlocking(^{
            imageView.hidden = NO;
            [photoCaptureButton setEnabled:YES];
        });

    }];
    
//    [stillCamera capturePhotoAsJPEGProcessedUpToFilter:filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
//
//        // Save to assets library
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        
//        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:stillCamera.currentCaptureMetadata completionBlock:^(NSURL *assetURL, NSError *error2)
//         {
//             if (error2) {
//                 NSLog(@"ERROR: the image failed to be written");
//             }
//             else {
//                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
//             }
//			 
//             runOnMainQueueWithoutDeadlocking(^{
//                 [photoCaptureButton setEnabled:YES];
//             });
//         }];
//    }];
}

- (IBAction)resume:(id)sender
{
    imageView.hidden = YES;
    [stillCamera resumeCameraCapture];
}

@end
