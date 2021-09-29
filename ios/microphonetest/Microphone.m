//
//  Microphone.m
//  microphonetest
//
//  Created by Ondrej Gonzor on 25.09.2021.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(MicrophoneRecording, RCTEventEmitter)

RCT_EXTERN_METHOD(toggleMicTap)
RCT_EXTERN_METHOD(start)

@end
