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

- (IBAction)onSlideOne:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
- (IBAction)onSlideTwo:(id)sender;

@property (weak, nonatomic) IBOutlet KSMetalView *metalView;

@end

