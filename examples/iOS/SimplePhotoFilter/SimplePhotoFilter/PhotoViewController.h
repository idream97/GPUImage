#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface PhotoViewController : UIViewController
{
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter, *secondFilter, *terminalFilter;
    UISlider *filterSettingsSlider;
    UIButton *photoCaptureButton;
    UIButton *resumeButton;
    UIButton *saveButton;
    
    UIImageView *imageView;
    
    GPUImagePicture *memoryPressurePicture1, *memoryPressurePicture2;
}

- (IBAction)updateSliderValue:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)save:(id)sender;

@end
