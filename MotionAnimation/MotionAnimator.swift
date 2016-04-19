//
//  MotionAnimator.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
@objc
public protocol MotionAnimatorObserver{
  func animatorDidUpdate(animator:MotionAnimator, dt:CGFloat)
}


private func sync(closure: () -> Void) {
  objc_sync_enter(MotionAnimator.sharedInstance)
  closure()
  objc_sync_exit(MotionAnimator.sharedInstance)
}

public class MotionAnimator: NSObject {
  public static let sharedInstance = MotionAnimator()
  var updateObservers:[MotionAnimationObserverKey:MotionAnimatorObserver] = [:]

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

    sync{
      for b in self.animations{
        b.willUpdate()
      }
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      sync {
        self._removeAllPendingStopAnimations()

        for b in self.animations{
          if !b.update(duration){
            self.pendingStopAnimations.append(b)
          }
        }
      }

      dispatch_async(dispatch_get_main_queue(), {
        sync {
          for b in self.animations{
            b.didUpdate()
            b.delegate?.animationDidPerformStep(b)
            b.onUpdate?(animation: b)
          }
          self._removeAllPendingStopAnimations()
          if self.animations.count == 0{
            self.displayLinkPaused = true
          }
        }
        for (_, o) in self.updateObservers{
          o.animatorDidUpdate(self, dt: duration)
        }
      })
    }

  }

  // must be called in mutex
  func _removeAllPendingStopAnimations(){
    for b in pendingStopAnimations{
      if let index = animations.indexOf(b){
        animations.removeAtIndex(index)
        b.delegate?.animationDidStop(b)
        b.onCompletion?(animation: b)
      }
    }
    pendingStopAnimations.removeAll()
  }

  public func addUpdateObserver(observer:MotionAnimatorObserver) -> MotionAnimationObserverKey {
    let key = NSUUID()
    updateObservers[key] = observer
    return key
  }

  public func observerWithKey(observerKey:MotionAnimationObserverKey) -> MotionAnimatorObserver? {
    return updateObservers[observerKey]
  }

  public func removeUpdateObserverWithKey(observerKey:MotionAnimationObserverKey) {
    updateObservers.removeValueForKey(observerKey)
  }

  public func addAnimation(b:MotionAnimation){
    sync {
      if let index = self.pendingStopAnimations.indexOf(b){
        self.pendingStopAnimations.removeAtIndex(index)
      }
      if self.animations.indexOf(b) == nil {
        self.animations.append(b)
        b.animator = self
        if self.displayLinkPaused {
          self.displayLinkPaused = false
        }
      }
    }
  }
  public func hasAnimation(b:MotionAnimation) -> Bool{
    return animations.indexOf(b) != nil && pendingStopAnimations.indexOf(b) == nil
  }
  public func removeAnimation(b:MotionAnimation){
    sync {
      if self.animations.indexOf(b) != nil {
        self.pendingStopAnimations.append(b)
      }
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




