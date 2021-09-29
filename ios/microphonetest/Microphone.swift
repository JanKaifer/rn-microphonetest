//
//  Microphone.swift
//  microphonetest
//
//  Created by Ondrej Gonzor on 25.09.2021.
//

import Foundation
import UIKit
import AVFAudio

@objc(MicrophoneRecording)
class MicrophoneRecording: RCTEventEmitter {
  private var audioEngine: AVAudioEngine!
  private var mic: AVAudioInputNode!
  private var micTapped = false
  
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  // we need to override this method and
  // return an array of event names that we can listen to
  override func supportedEvents() -> [String]! {
    return ["onRecording"]
  }
 
  override init() {
    super.init()
    audioEngine = AVAudioEngine()
    mic = audioEngine.inputNode
  }
  
  deinit {
    stopAudioPlayback()
  }
  
  @objc
  func toggleMicTap() {
    if micTapped {
      mic.removeTap(onBus: 0)
      micTapped = false
      return
    }
    
    let micFormat = mic.inputFormat(forBus: 0)
//    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
    mic.installTap(onBus: 0, bufferSize: 4096, format: micFormat) { (buffer, when) in
      guard
        let channelData = buffer.floatChannelData
      else {
        return
      }
      
      let channelDataValue = channelData.pointee

      let channelDataValueArray = stride(from: 0,
                                         to: Int(buffer.frameLength),
                                         by: buffer.stride).map{ channelDataValue[$0] }
      
      self.sendEvent(withName: "onRecording", body: ["data": channelDataValueArray])
    }
    
    micTapped = true
    startEngine()
  }
  
  // MARK: Internal Methods
  
 
  
  private func startEngine() {
    guard !audioEngine.isRunning else {
      return
    }
    
    do {
      try audioEngine.start()
    } catch { }
  }
  
  private func stopAudioPlayback() {
    audioEngine.stop()
    audioEngine.reset()
  }
  
  var inputQueue: AudioQueueRef? = nil
  var buffer: AudioQueueBufferRef? = nil
  let bufferSize: UInt32 = 4096

  
  @objc
  func start() {
//    super.init()
    let sampleRate: Float64 = 44100
    let bitsPerChannel: UInt32 = 16
    let channelsPerFrame: UInt32 = 1
    
    
    var description = AudioStreamBasicDescription(mSampleRate: sampleRate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger, mBytesPerPacket: 2, mFramesPerPacket: 1, mBytesPerFrame: 2, mChannelsPerFrame: channelsPerFrame, mBitsPerChannel: bitsPerChannel, mReserved: 0)
    var status: OSStatus = 0
    
    
    let selfPointer = Unmanaged.passUnretained(self).toOpaque()


    status = AudioQueueNewInput(&description, { (inUserData: UnsafeMutableRawPointer?, inAQ: AudioQueueRef, inBuffer: AudioQueueBufferRef, inStartTime: UnsafePointer<AudioTimeStamp>, inNumPackets: UInt32, inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?) -> Void in
      print("call")
      guard let unwrappedInUserData = inUserData else {
        return
      }
      
      let this =  Unmanaged<MicrophoneRecording>.fromOpaque(unwrappedInUserData).takeUnretainedValue()
      
      //let audioData = Int16(Int(bitPattern: inBuffer.pointee.mAudioData))
      let audioData = inBuffer.pointee.mAudioData.assumingMemoryBound(to: Int16.self)
//      let count = inBuffer.pointee.mAudioDataByteSize / UInt32(MemoryLayout.size(ofValue: Int16.self))

//      var myAudioData: UnsafeMutablePointer<NSNumber>! = UnsafeMutablePointer.allocate(capacity: 65536)
//      for i in 0...this.bufferSize - 1 {
//        myAudioData[Int(i)] = NSNumber(value: audioData[Int(i)])
//      }
      print("call 2")
      this.sendEvent(withName: "onRecording", body: ["data": NSArray(objects: audioData)])
      
    }, selfPointer, nil, nil, 0, &inputQueue)
    
    if status != noErr {
      fatalError("error initializing microphone audio queue")
    }
    
    status = AudioQueueAllocateBuffer(inputQueue!, bufferSize * 2,  &buffer)
    
    if status != noErr {
      fatalError("error initializing microphone audio buffer")
    }
    
    status = AudioQueueEnqueueBuffer(inputQueue!, buffer!, 0, nil)
    
    if status != noErr {
      fatalError("error enqueing microphone audio buffer")
    }
    
    status = AudioQueueStart(inputQueue!, nil);
    
    if status != noErr {
      fatalError("error startin microphone audio queue")
    }
  }

  
  func audioQueueInputCallback(inUserData: UnsafeMutableRawPointer?,
                               inQueue: AudioQueueRef,
                               inBuffer: AudioQueueBufferRef,
                               inStartTime: UnsafePointer<AudioTimeStamp>,
                               inNumPackets: UInt32,
                               inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?) {
    // Handle stuff
  }
  
 
}
