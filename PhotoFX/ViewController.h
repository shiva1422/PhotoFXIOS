//
//  ViewController.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 9/22/23.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

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

@end

