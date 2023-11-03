//
//  FileImporter.m
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/26/23.
//

#import "FileImporter.h"
#import <Photos/Photos.h>
#include "KSLog.hpp"
#import <UIKit/UIKit.h>

@implementation FileImporter

+(BOOL)authorizePhotosAccess
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status)
    {
        case PHAuthorizationStatusAuthorized:return YES;
        case PHAuthorizationStatusDenied:KSLogE("Photo access denied");
        case PHAuthorizationStatusNotDetermined:
        {
            PHAuthorizationStatus res = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
            if(res != PHAuthorizationStatusAuthorized)
            {
              /*  dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photo Access" message:@"Authorization needed" preferredStyle:UIAlertControllerStyleAlert];
                    
                    id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
                    if([rootViewController isKindOfClass:[UINavigationController class]])
                    {
                        rootViewController = ((UINavigationController *)rootViewController).viewControllers.firstObject;
                    }
                    if([rootViewController isKindOfClass:[UITabBarController class]])
                    {
                        rootViewController = ((UITabBarController *)rootViewController).selectedViewController;
                    }
                    //...
                    [rootViewController presentViewController:alertController animated:YES completion:nil];
                });*/
                KSLogE("Photo Access not authorized");
                return NO;
            }
         }
    }
    return YES;
}
@end
