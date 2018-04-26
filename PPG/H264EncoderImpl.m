//
//  H264EncoderImpl.m
//  PPG
//
//  Created by oucaizi on 2017/9/7.
//  Copyright © 2017年 oucaizi. All rights reserved.
//

/**VideoToolbox框架用于视频的硬编码解码**/

#import "H264EncoderImpl.h"
#import <VideoToolbox/VideoToolbox.h>


@interface H264EncoderImpl()
{
    dispatch_queue_t  gQueue;// 队列
    VTCompressionSessionRef EncodingSession;//硬编码上下文
}

@end

@implementation H264EncoderImpl
@synthesize error;

/**
 初始化VTCompressionSession硬编码信息 需要设置宽高
 
 @param width 宽
 @param height 高
 */
- (void) initEncode:(int)width  height:(int)height
{
    dispatch_sync(gQueue, ^{
       
        // VTCompressionSession初始化  didCompressH264（编码成功后的回调函数）
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self), &EncodingSession);
        NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
        
        // 当status不为0 表示创建VTCompressionSession 失败
        if (status != 0)
        {
            NSLog(@"H264: Unable to create a H264 session");
            error = @"H264: Unable to create a H264 session";
            return ;
        }
        
        // 设置属性 可以设置帧率相关的
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
        
        // 告诉编码器准备编码
        VTCompressionSessionPrepareToEncodeFrames(EncodingSession);
    });
}


/**
 进行硬件编码
 
 @param sampleBuffer  未经编码的摄像头采集到的数据
 */
- (void) encode:(CMSampleBufferRef )sampleBuffer
{
    
}


void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags,
                     CMSampleBufferRef sampleBuffer )
{
    
}


// 使用VTCompressionSession 进行硬编码 需要设置 h(高) w(宽度)
-(void)start
{
    
}

@end
