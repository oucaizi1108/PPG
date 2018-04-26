//
//  H264EncoderImpl.h
//  PPG
//
//  Created by oucaizi on 2017/9/7.
//  Copyright © 2017年 oucaizi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface H264EncoderImpl : NSObject

@property (weak, nonatomic) NSString *error;

/**
 初始化VTCompressionSession硬编码信息 需要设置宽高

 @param width 宽
 @param height 高
 */
- (void) initEncode:(int)width  height:(int)height;


/**
 进行硬件编码

 @param sampleBuffer  未经编码的摄像头采集到的数据
 */
- (void) encode:(CMSampleBufferRef )sampleBuffer;

@end
