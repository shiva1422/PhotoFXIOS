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
#import "KSFilterRenderer.h"
#include "FilterCommon.hpp"

@interface ViewController ()
{
    std::mutex filterLock;
    ImageEditContext filter;
    
    float r,g,b,a;
    bool grayScale,channelLock;
    //flags below indicate if editing is enabled for channels
    bool rEnable,bEnable,gEnable,AEnable;
    std::string mainOption,subOption;
    //TODO default;
}

@property(strong,nonatomic) Editorpreview* preview;
@property(weak,nonatomic) KSFilterRenderer* filterRenderer;



@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _rSlider.maximumValue = 5.0;
    _rSlider.minimumValue = 0.0;
    _gSlider.maximumValue = 5.0;
    _gSlider.minimumValue = 0.0;
    _bSlider.maximumValue = 5.0;
    _bSlider.minimumValue = 0.0;
    _aSlider.maximumValue = 5.0;
    _aSlider.minimumValue = 0.0;
    mainOption = "Intensity";
    subOption = "log";
    // Do any additional setup after loading the view.
   // _preview = [[Editorpreview alloc] initWithFrame:self.view.bounds];
   // [self.view addSubview:_preview];
    //_preview.image =
    //KSMetalView *view =(KSMetalView *) self.view;
    _filterRenderer = (KSFilterRenderer *)_metalView.delegate;
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
                    
                    //self->imageEditor->addImage(url.absoluteString.UTF8String);
                    _filterRenderer = (KSFilterRenderer *)_metalView.delegate;
                    [_filterRenderer setImage:url.absoluteString.UTF8String];
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
    
    UISlider* slider = sender;
    KSLogD("Slider value %f",slider.value);
    
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
- (IBAction)onMainOptionChange:(id)sender {
    
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    NSInteger index = [segment selectedSegmentIndex];
    
    mainOption = [segment titleForSegmentAtIndex:index].UTF8String;
    
    KSLogD("on mainoption changed %s",mainOption.c_str());
    //todo change the suboption segments;
    
}

- (IBAction)onSubOptionChange:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    NSInteger index = [segment selectedSegmentIndex];
    subOption = [segment titleForSegmentAtIndex:index].UTF8String;
    
    KSLogD("on suboption changed %s",subOption.c_str());
    
    if(subOption == "contrast" || subOption == "slice")
    {
        _rSlider.maximumValue = 1.0;
        _rSlider.minimumValue = 0.0;
        _gSlider.maximumValue = 1.0;
        _gSlider.minimumValue = 0.0;
        _bSlider.maximumValue = 1.0;
        _bSlider.minimumValue = 0.0;
        _aSlider.maximumValue = 1.0;
        _aSlider.minimumValue = 0.0;
        KSLogE("Contrast strecthing make sure the r1<=r2,s1<=s2 follow monotonously increasing curve");
    }
    std::string shader = ImageEditContext::getFragmentShaderName(mainOption, subOption);
    
    [self setShader:shader];
    
}
- (IBAction)onSliderFlagChanged:(id)sender {
    UISegmentedControl *sliderFlag = (UISegmentedControl *)sender;
    switch(sliderFlag.selectedSegmentIndex)
    {
       // case 0 : //rgb
            
    }
    
    
}
- (IBAction)onSliderLockChange:(id)sender {
    
    channelLock != channelLock;//TODO update any Params as necessary
    
}
- (IBAction)onGrayScaleSwitch:(id)sender {
    
    UISwitch *graySwitch = (UISwitch *)sender;

    if(graySwitch.isOn)
    {
        filter.grayScaleSwitch = true;
        KSLogD("GrayScale On");
        _aSlider.hidden = false;
        _gSlider.hidden = false;
        _bSlider.hidden = false;
        filter.channel = EActiveChannel::RGB;
        
    }
    else
    {
        filter.grayScaleSwitch = false;
        KSLogD("GrayScale Off");
        _aSlider.hidden = true;
        _gSlider.hidden = true;
        _bSlider.hidden = true;
        filter.channel = EActiveChannel::RGB;
    }
    

}
- (IBAction)onRSlider:(id)sender {
    UISlider* slider = sender;
    KSLogD("Slider value r %f",slider.value);
    [self onUpdateChannelParam:slider.value channel:EActiveChannel::R];
   

}
- (IBAction)onASlider:(id)sender {
    UISlider* slider = sender;
    KSLogD("Slider value a %f",slider.value);
    [self onUpdateChannelParam:slider.value channel:EActiveChannel::A];

    
}
- (IBAction)onBSlider:(id)sender {
    UISlider* slider = sender;
    KSLogD("Slider value b  %f",slider.value);
    [self onUpdateChannelParam:slider.value channel:EActiveChannel::B];

    
}

- (IBAction)onGSlider:(id)sender {
    
    UISlider* slider = sender;
    KSLogD("Slider value g%f",slider.value);
    [self onUpdateChannelParam:slider.value channel:EActiveChannel::G];

   
}

-(void)initParams
{
     r = 1.0,g=1.0,b=1.0,a=1.0;
     grayScale = false,channelLock = false;
     rEnable = true,bEnable = true,gEnable = true,AEnable = true;
}

-(void)onUpdateChannelParam:(float) paramVal channel:(EActiveChannel)channelType
{
    if(grayScale || channelLock)
    {
        r = g = b = paramVal;
    }
    else
    {
      switch(channelType)
      {
            case EActiveChannel::R:
              r = paramVal;
              break;
            case EActiveChannel::G:
              g = paramVal;
              break;
            case EActiveChannel::B:
              b = paramVal;
              break;
            case EActiveChannel::A:
              a = paramVal;
            break;
          default:
              assert(false);
      }
    }
    
    [self updateFilter];
}

-(void)updateFilter
{
    if(channelLock || grayScale)
    {
        _rSlider.value = r;
        _gSlider.value = g;
        _bSlider.value = b;
        _aSlider.value = a;
        
    }
    
    FilterParams params;//instead KeepMember param and update only changed values;
    
    KSLogD("update UI Filter %f %f %f %f",r,g,b,a);
    params.scaleFactor[0] = r;
    params.scaleFactor[1] = g;
    params.scaleFactor[2] = b;
    params.scaleFactor[3] = a;
    
    params.bGrayScale = grayScale;
    params.flags[0] = rEnable ? 1 : 0;
    params.flags[1] = bEnable ? 1 : 0;
    params.flags[2] = gEnable ? 1 : 0;
    params.flags[3] = AEnable ? 1 : 0;
    
    _filterRenderer = (KSFilterRenderer *)_metalView.delegate;
    [_filterRenderer updateFilterParams:params];
    
}

-(void)setShader:(std::string) shader
{
    //TODO reset FilterParams
    _filterRenderer = (KSFilterRenderer *)_metalView.delegate;
    [_filterRenderer setActiveFragShader:shader];
}
@end
