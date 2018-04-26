//
//  ViewController.m
//  PPG
//
//  Created by oucaizi on 2017/8/4.
//  Copyright © 2017年 oucaizi. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageView.h"

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
   NSMutableArray *points;
}
@property(nonatomic,strong) AVCaptureSession * session;//输入输出会话
@property(nonatomic,strong) AVCaptureDeviceInput *videoDeviceInput;//视频输入流
@property(nonatomic,strong) AVCaptureVideoDataOutput *videoOutput;//视频输出流
@property(nonatomic,strong) UIImageView * rateImage;//绘制心率图

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.rateImage = [UIImageView new];
     self.rateImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 300);
    [self.rateImage setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.rateImage];
    [self setupCaputureVideo];

    
}

// 捕获音视频
- (void)setupCaputureVideo
{
    // 1.创建捕获会话,必须要强引用，否则会被释放
    AVCaptureSession * captureSession = [[AVCaptureSession alloc] init];
    _session = captureSession;
    
    // 2.开始配置AVCaptureSession
    [_session beginConfiguration];
    
    if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        /** 降低图像采集的分辨率 */
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    // 3.获取摄像头设备，默认是后置摄像头,并进行相关配置白平衡、对焦等参数
    AVCaptureDevice * videoDevice = [self getVideoDevice:AVCaptureDevicePositionBack];
    if ([videoDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
        NSError *error = nil;
        /** 锁定设备以配置参数 */
        [videoDevice lockForConfiguration:&error];
        if (error) {
            return;
        }
        [videoDevice setTorchMode:AVCaptureTorchModeOn];
        [videoDevice unlockForConfiguration];//解锁
    }
    
    // 4.创建对应视频设备输入对象
    NSError *error = nil;
    AVCaptureDeviceInput * videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    _videoDeviceInput = videoDeviceInput;
    if (error) {
        NSLog(@"DeviceInput error:%@", error.localizedDescription);
        return;
    }
    
    // 5.添加视频输入流
    if ([_session canAddInput:_videoDeviceInput])
    {
        [_session addInput:_videoDeviceInput];
    }
    
    // 6.获取视频数据输出设备
    AVCaptureVideoDataOutput * videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSNumber *BGRA32PixelFormat = [NSNumber numberWithInt:kCVPixelFormatType_32BGRA];
    NSDictionary *rgbOutputSetting;
    rgbOutputSetting = [NSDictionary dictionaryWithObject:BGRA32PixelFormat
                                                   forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoOutput setVideoSettings:rgbOutputSetting];    // 设置像素输出格式
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES]; // 抛弃延迟的帧

    _videoOutput = videoOutput;
    
    dispatch_queue_t videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [_videoOutput setSampleBufferDelegate:self queue:videoQueue];
    
    AVCaptureConnection* connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    // 7.添加视频输出流
    if ([_session canAddOutput:_videoOutput])
    {
        [_session addOutput:_videoOutput];
    }
    
    // 8.提交配置
    [_session commitConfiguration];
    
    // 9.开始数据传输
    [_session startRunning];

}

// 指定摄像头方向获取摄像头
- (AVCaptureDevice *)getVideoDevice:(AVCaptureDevicePosition)position
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == position) {
                return device;
            }
        }
        return nil;
    #pragma clang diagnostic pop
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    /** 读取图像Buffer */
//    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
////    NSLog(@"==%@",imageBuffer);
//    
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
////    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//    uint8_t *buf = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//
//    float r = 0, g = 0,b = 0;
//    for(int y = 0; y < height; y++) {
//        for(int x = 0; x < width * 4; x += 4) {
//            b += buf[x];
//            g += buf[x+1];
//            r += buf[x+2];
//        }
//        buf += bytesPerRow;
//    }
//    r /= 255 * (float)(width * height);
//    g /= 255 * (float)(width * height);
//    b /= 255 * (float)(width * height);
//    
//    float h,s,v;
//    RGBtoHSV(r, g, b, &h, &s, &v);
//    static float lastH = 0;
//    float highPassValue = h - lastH;
//    lastH = h;
//    float lastHighPassValue = 0;
//    float lowPassValue = (lastHighPassValue + highPassValue) / 2;
//    lastHighPassValue = highPassValue;
//    
//    [self rendervalue:[NSNumber numberWithFloat:lowPassValue]];
    
  
}

- (void)rendervalue:(NSNumber *)value
{
    if(!points)
        points = [NSMutableArray new];
    [points insertObject:value atIndex:0];
    while(points.count > 120)
    {
        [points removeLastObject];
    }
   
    if(points.count == 0)
        return;
   
    UIGraphicsBeginImageContextWithOptions(self.rateImage.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1);
    
    CGContextSaveGState(context);
    
    float xpos = 0;
    float ypos = 0;
    CGContextMoveToPoint(context, xpos, ypos);
    NSInteger count = points.count;
    for(NSInteger i = 0; i<count ; i++)
    {
        xpos = (self.rateImage.bounds.size.width/count)*i;
        ypos = [[points objectAtIndex:i] floatValue];
        CGContextAddLineToPoint(context, xpos, self.rateImage.bounds.size.height / 2 + ypos * self.rateImage.bounds.size.height / 2);

    }
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    UIImage * renderImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [CATransaction setDisableActions:YES];
        [CATransaction begin];
        self.rateImage.image = renderImage;
        [CATransaction commit];
      
    });
    
  
}


void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h = 2 + (b - r) / delta;
    else
        *h = 4 + (r - g) / delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
