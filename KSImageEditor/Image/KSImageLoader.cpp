//
//  KSImageLoader.cpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/20/23.
//

#include "KSImageLoader.hpp"
#include <ImageIO/CGImageSource.h>
#include "KSLog.hpp"


void printExifData(CFDictionaryRef metadata)
{
    /*
     class ExifData: NSObject {
       var colorModel: String?;
       var pixelWidth: Double?;
       var pixelHeight: Double?;
       var dpiWidth: Int?;
       var dpiHeight: Int?;
       var depth: Int?;
       var orientation: Int?;
       var apertureValue: String?;
       var brightnessValue: String?;
       var dateTimeDigitized: String?;
       var dateTimeOriginal: String?;
       var offsetTime: String?;
       var offsetTimeDigitized: String?;
       var offsetTimeOriginal: String?;
       var model: String?;
       var software: String?;
       var tileLength: Double?;
       var tileWidth: Double?;
       var xResolution: Double?;
       var yResolution: Double?;
       var altitude: String?;
       var destBearing: String?;
       var hPositioningError: String?;
       var imgDirection: String?;
       var latitude: String?;
       var longitude: String?;
       var speed: Double?;
     */
}
KSImage* KSImageLoader::loadImage(const char *path)
{
    
    KSImage *image = new KSImage;
    
    CGImageRef        imageRef = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[2];
    CFTypeRef         myValues[2];
     
    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
    CFStringRef cfile = CFStringCreateWithCString(NULL, path, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(NULL, cfile, NULL);
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    // Create the dictionary
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                       (const void **) myValues, 2,
                       &kCFTypeDictionaryKeyCallBacks,
                       & kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((CFURLRef)url, myOptions);
        CFRelease(myOptions);
    
    //TODO debug
    CFDictionaryRef meta = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    //printExifData(meta);
//    CFRelease(meta);
    
    
    
    // Make sure the image source exists before continuing
    if (myImageSource == NULL)
    {
            fprintf(stderr, "Image source is NULL");
            return  NULL;
    }
        // Create an image from the first item in the image source.
    imageRef = CGImageSourceCreateImageAtIndex(myImageSource,0,NULL);
    
   
    
    //create a suitable bitmap context fro extracting the bits of the image;
    uint width  = CGImageGetWidth(imageRef);
    uint height = CGImageGetHeight(imageRef);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    image->data  = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    image->width = width;
    image->height = height;
    image->pixelFmt = EPixelFormat::RGBA8;
    uint bytesPerPixel = 4;//TODO;
    uint bytesPerRow = bytesPerPixel * width;
    uint bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(image->data, width, height, bitsPerComponent, bytesPerRow,colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    //Flip the context so the +Y points down.
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0,0,width,height), imageRef);
    CGContextRelease(context);
     
    CFRelease(myImageSource);
    CFRelease(url);
    CFRelease(cfile);
    // Make sure the image exists before continuing
    if (imageRef == NULL)
    {
        KSLogE("KSImageLoader : error loading image");
        assert(false);//TODO
    }
    CFRelease(imageRef);

    return image;
}

void KSImageLoader::loadImageAsync(std::string path, KSImageDecodeListener *listener)
{
   // KSImage *image = loadImage(path.c_str());
   //if(listener)
   // listener->onImageAvailable(image);
    
}
