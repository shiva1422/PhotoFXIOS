//
//  KSMetalView.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/10/23.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN


@protocol KSMetalViewDelegate;


@interface KSMetalView : UIView

//Backing CA metal layer for the view
@property (readonly) CAMetalLayer *metalLayer;

//color attachment pixel format:
@property (nonatomic) MTLPixelFormat pixelFmt;

//color to clear at the beginning of render pass
@property (nonatomic ,assign) MTLClearColor clearColor;

@property (nonatomic) NSInteger fps;


//delegate for the view ,responsible for rendering
@property(nonatomic) id<KSMetalViewDelegate> delegate;


@property(nonatomic ,readonly)NSTimeInterval frameDuration;

@property(nonatomic , readonly) id<CAMetalDrawable> currentDrawable;


//renderpassDesc configured to use current drawble texture as primary color attachment and internal depth texture of same size as its depth attachment texture.

@property(nonatomic,readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;

-(MTLRenderPassDescriptor *)getCurrentRenderPassDescriptor;


//- (instancetype)initWithCoder:(NSCoder *)decoder ;//if not loading from storyboard;


@end


@protocol KSMetalViewDelegate <NSObject>

//called once per frame any of the properties of the view can be accessed and request currentRenderPassDesc as well.
-(void)onRender:(KSMetalView *)view;

@end

NS_ASSUME_NONNULL_END
