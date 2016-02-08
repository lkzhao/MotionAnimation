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
    for b in animations{
      if !b.update(CGFloat(displayLink.duration)){
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




