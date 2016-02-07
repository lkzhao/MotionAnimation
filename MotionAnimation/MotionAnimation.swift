//
//  MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

protocol MotionAnimationDelegate{
  func animationDidStop(animation:MotionAnimation)
  func animationDidPerformStep(animation:MotionAnimation)
}

class MotionAnimation: NSObject {
  internal var animator:MotionAnimator?
  internal weak var parentAnimation:MotionAnimation?
  internal var childAnimations:[MotionAnimation] = []
  
  var delegate:MotionAnimationDelegate?
  var onCompletion:((animation:MotionAnimation) -> Void)?
  var onUpdate:((animation:MotionAnimation) -> Void)?

  var playing:Bool{
    return MotionAnimator.sharedInstance.hasAnimation(self)
  }
  
  override init() {
    super.init()
    MotionAnimator.sharedInstance.addAnimation(self)
  }
  
  func addChildBehavior(b:MotionAnimation){
    if childAnimations.indexOf(b) == nil{
      childAnimations.append(b)
      b.parentAnimation = self
    }
  }
  
  func play(){
    if parentAnimation == nil{
      MotionAnimator.sharedInstance.addAnimation(self)
    }
  }
  
  func stop(){
    if parentAnimation == nil{
      MotionAnimator.sharedInstance.removeAnimation(self)
    }
  }
  
  // returning true means require next update(not yet reached target state)
  // behaviors can call animator.addAnimation to wake up the animator when
  // the target value changed
  func update(dt:CGFloat) -> Bool{
    var running = false
    for c in childAnimations{
      if c.update(dt){
        running = true
      }
    }
    return running
  }
}
