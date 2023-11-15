//
//  ViewController.m
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 9/22/23.
//

#import "ViewController.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include "KSImageEditor.hpp"
#import "Editorpreview.h"
#import "FileImporter.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "KSLog.hpp"

@interface ViewController ()
{
    float slider1Value;
}

@property(strong,nonatomic) Editorpreview* preview;


@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _slider1.maximumValue = 1.0;
    _slider1.minimumValue = 0.0;
    _slider2.maximumValue = 1.0;
    _slider2.minimumValue = 0.0;
    
    // Do any additional setup after loading the view.
   // _preview = [[Editorpreview alloc] initWithFrame:self.view.bounds];
   // [self.view addSubview:_preview];
    //_preview.image =
    imageEditor = new KSImageEditor(self.view.bounds.size.width, self.view.frame.size.height);
    KSLogI("View did load");
    //imageEditor->setResolution();
   // [FileImporter authorizePhotosAccess];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    KSLogD("View did appear");
}
- (IBAction)onImportImageClick:(id)sender
{
    
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 1;
    config.filter = [PHPickerFilter imagesFilter];
    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc]initWithConfiguration:config];
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:^{
        
        KSLogD("PHPickerViewController completed");
    }];
  /*  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];*/
    
}

-(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
{
    NSLog(@"-picker:%@ didFinishPicking:%@", picker, results);
    
    
    for (PHPickerResult *result in results)
    {
        NSLog(@"result: %@", result);
        
        NSLog(@"%@", result.assetIdentifier);
        NSLog(@"%@", result.itemProvider);
        
        // Get UIImage
        /* [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
         NSLog(@"object: %@, error: %@", object, error);
         
         if ([object isKindOfClass:[UIImage class]]) {
         dispatch_async(dispatch_get_main_queue(), ^{
         UIImageView *imageView = [self newImageViewForImage:(UIImage*)object];
         [self->imageViews addObject:imageView];
         [self->scrollView addSubview:imageView];
         [self.view setNeedsLayout];
         });
         }
         }];*/
        
        // Get file
        if([result.itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage])
        {
            [result.itemProvider loadFileRepresentationForTypeIdentifier:(NSString *)kUTTypeImage completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    self->imageEditor->addImage(url.absoluteString.UTF8String);
                    [picker dismissViewControllerAnimated:YES completion:nil];

                });
                       // do some work in the background
            }];
            
        }
        
        

             
    }
    

}

/*-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *imagePicked = info[UIImagePickerControllerEditedImage];
    NSLog(@"image picked %@ url %@",imagePicked.description,[info[UIImagePickerControllerReferenceURL] description]);
    imageEditor->addImage([info[UIImagePickerControllerReferenceURL] description].UTF8String);
    [picker dismissViewControllerAnimated:YES completion:nil];
}*/

- (IBAction)onSlideOne:(id)sender {
    
    if(slider1Value != self.slider1.value)
    {
        //Pass slider value;
    }
}

- (IBAction)onBrowseFilesClick:(id)sender {
    
   /* UTType utiTypes[] = {UTType.image, .movie, .video, .mp3, .audio, .quickTimeMovie, .mpeg, .mpeg2Video, .mpeg2TransportStream, .mpeg4Movie, .mpeg4Audio, .appleProtectedMPEG4Audio, .appleProtectedMPEG4Video, .avi, .aiff, .wav, .midi, .livePhoto, .tiff, .gif, UTType("com.apple.quicktime-image"), .icns};*/

/*    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeImage]];//@[UTTypeVideo,UTTypeGIF,UTTypeImage]

    
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = YES;
    documentPicker.editing = YES;//TODO check
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;

    
    [self presentViewController:documentPicker animated:YES completion:nil];*/
    
}

/*-(void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
          NSString *alertMessage = [NSString stringWithFormat:@"Successfully imported %@", [urls[0] description]];
    if(urls[0] != nil)
    {
        imageEditor->addImage(urls[0].description.UTF8String);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Import"
                                              message:alertMessage
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
    //TODO clear.
}
  */

- (IBAction)onSlideTwo:(id)sender {
}
@end
