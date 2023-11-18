//
//  ViewController.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 9/22/23.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "KSMetalView.h"

struct KSImageEditor;
//TODO
@interface ViewController : UIViewController<PHPickerViewControllerDelegate>
{
    struct KSImageEditor *imageEditor;
}
@property (weak, nonatomic) IBOutlet UIButton *ImportButton;

- (IBAction)onImportImageClick:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *fileButton;

- (IBAction)onBrowseFilesClick:(id)sender;


@property (weak, nonatomic) IBOutlet UISlider *rSlider;
@property (weak, nonatomic) IBOutlet UISlider *gSlider;
@property (weak, nonatomic) IBOutlet UISlider *bSlider;
@property (weak, nonatomic) IBOutlet UISlider *aSlider;

- (IBAction)onRSlider:(id)sender;
- (IBAction)onGSlider:(id)sender;
- (IBAction)onBSlider:(id)sender;
- (IBAction)onASlider:(id)sender;

/*
 options
 */
@property (weak, nonatomic) IBOutlet UISegmentedControl *mainOptions;
- (IBAction)onMainOptionChange:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *subOptions;

- (IBAction)onSubOptionChange:(id)sender;

@property (weak, nonatomic) IBOutlet KSMetalView *metalView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sliderFlagsSegment;
- (IBAction)onSliderFlagChanged:(id)sender;

//locked means rgb change same;
@property (weak, nonatomic) IBOutlet UISwitch *sliderLock;
- (IBAction)onSliderLockChange:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *graySwitch;
- (IBAction)onGrayScaleSwitch:(id)sender;


@end

