//
//  KSMetalView.m
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/10/23.
//

#import "KSMetalView.h"
#import "KSTextureRenderer.h"
#import "KSFilterRenderer.h"
static bool bFirst = true;//TODO

@interface KSMetalView()

@property (strong) id<CAMetalDrawable> currentDrawable;
@property (assign) NSTimeInterval frameDuration;
@property (strong) id<MTLTexture> depthTexture;
@property (strong) CADisplayLink *displayLink;

@end



@implementation KSMetalView



-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        _fps = 60;
        _clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        self.metalLayer.device = MTLCreateSystemDefaultDevice();
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame device:(id<MTLDevice>)device
{
    if((self = [super initWithFrame:frame]))
    {
        _fps = 60;
        _clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        self.metalLayer.device = device;
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    
    //During the first layout pass,view hierarchy is not crated so guess the scale
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    //if moved to windoe by the time frame is set,scale can be set as from window
    
    if(self.window)
    {
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    
    //since drawable size is in pixels ,multipy by scale to move from points to pixels
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
    
    [self createDepthTexture];
}

-(void)createDepthTexture
{
    CGSize drawableSize = self.metalLayer.drawableSize;
    
    if([self.depthTexture width] != drawableSize.width || [self.depthTexture height] != drawableSize.height || bFirst)
    {
        
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:drawableSize.width height:drawableSize.height mipmapped:NO];
        
        desc.usage = MTLTextureUsageRenderTarget;
        desc.storageMode = MTLStorageModePrivate;
        
        self.depthTexture = [self.metalLayer.device newTextureWithDescriptor:desc];
        
        bFirst = false;
    }
    
}

-(void)setColorPixelFormat:(MTLPixelFormat)colorPixelFormat
{
    self.metalLayer.pixelFormat = colorPixelFormat;
}

-(MTLPixelFormat)colorPixelFormat
{
    return self.metalLayer.pixelFormat;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if(self.superview)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector((displayLinkDidFire:))];
        
       [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];//to keep draw with device sync.
    }
    else
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

-(void)didMoveToWindow
{
    const NSTimeInterval idealFrameDur = (1.0/60);
    const NSTimeInterval targetFrameDur = (1.0 /self.fps);
    const NSInteger frameInterval = round(targetFrameDur/idealFrameDur);
    
    if(self.window)
    {
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        
        //TODO deprecated
        self.displayLink.frameInterval = frameInterval;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

-(void)displayLinkDidFire:(CADisplayLink *)displayLink
{
    if(!self.delegate)
    {
        self.delegate = [KSFilterRenderer new];//TODO move to appropriate location;
    }
    self.currentDrawable = self.metalLayer.nextDrawable;
    self.frameDuration = displayLink.duration;
   
    if(self.currentDrawable && self.depthTexture != nil && [self.delegate respondsToSelector:@selector(onRender:)])
    {
        [self.delegate onRender:self];
    }
    else
    {
        NSLog(@"DisplayLink Did Fire drawable error");
    }
}

-(MTLRenderPassDescriptor *)getCurrentRenderPassDescriptor
{
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    
    passDescriptor.colorAttachments[0].texture = [self.currentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.clearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    assert(self.depthTexture != nil);
    passDescriptor.depthAttachment.texture = self.depthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    
    return passDescriptor;
    
}

-(CAMetalLayer *)metalLayer
{
    return (CAMetalLayer *)self.layer;
}

+(id)layerClass
{
    return [CAMetalLayer class];
}

-(void)dealloc
{
    [_displayLink invalidate];
}

@end
