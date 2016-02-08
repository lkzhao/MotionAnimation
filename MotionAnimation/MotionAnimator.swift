//
//  MotionAnimator.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public class MotionAnimator: NSObject {
  public static let sharedInstance = MotionAnimator()
  var updateCallbacks:[NSUUID:((dt:CGFloat)->Void)] = [:]
  
  public var debugEnabled = false
  var displayLinkPaused:Bool{
    get{
      return displayLink == nil
    }
    set{
      newValue ? stop() : start()
    }
  }
  var animations:[MotionAnimation] = []
  var pendingStopAnimations:[MotionAnimation] = []
  var displayLink : CADisplayLink!
  
  override init(){
    super.init()
  }
  
  func update() {
    let duration = CGFloat(displayLink.duration)
    for b in animations{
      if !b.update(duration){
        pendingStopAnimations.append(b)
      }
      b.delegate?.animationDidPerformStep(b)
      b.onUpdate?(animation: b)
    }
    
    for b in pendingStopAnimations{
      if let index = animations.indexOf(b){
        animations.removeAtIndex(index)
        b.delegate?.animationDidStop(b)
        b.onCompletion?(animation: b)
      }
    }

    pendingStopAnimations.removeAll()
    if animations.count == 0{
      displayLinkPaused = true
    }
    for (_, callback) in updateCallbacks{
      callback(dt:duration)
    }
  }

  public func addUpdateCallback(callback:(dt:CGFloat)->Void) -> MotionAnimationObserverKey{
    let uuid = NSUUID()
    self.updateCallbacks[uuid] = callback
    return uuid
  }
  
  public func removeUpdateCallback(key:MotionAnimationObserverKey) {
    self.updateCallbacks.removeValueForKey(key)
  }

  public func addAnimation(b:MotionAnimation){
    if animations.indexOf(b) == nil {
      animations.append(b)
      b.animator = self
      if displayLinkPaused {
        displayLinkPaused = false
      }
    }
  }
  public func hasAnimation(b:MotionAnimation) -> Bool{
    return animations.indexOf(b) != nil
  }
  public func removeAnimation(b:MotionAnimation){
    if animations.indexOf(b) != nil {
      pendingStopAnimations.append(b)
    }
  }
  
  func start() {
    if !displayLinkPaused{
      return
    }
    displayLink = CADisplayLink(target: self, selector: Selector("update"))
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    printDebugMsg("displayLink started")
  }
  
  func stop() {
    if displayLinkPaused{
      return
    }
    displayLink.paused = true
    displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    displayLink = nil
    printDebugMsg("displayLink ended")
  }
  
  func printDebugMsg(str:String){
    if debugEnabled { print(str) }
  }
}




