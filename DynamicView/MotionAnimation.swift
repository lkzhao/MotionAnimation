//
//  MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class MotionAnimation: NSObject {
  internal weak var obj:NSObject?{
    didSet{
      obj != nil ? play() : stop()
    }
  }
  internal var animator:MotionAnimator?
  internal weak var parentBehavior:MotionAnimation?
  internal var childBehaviors:[MotionAnimation] = []
  var playing:Bool{
    return MotionAnimator.sharedInstance.hasAnimation(self)
  }
  
  override init() {
    super.init()
    MotionAnimator.sharedInstance.addAnimation(self)
  }
  
  func addChildBehavior(b:MotionAnimation){
    if childBehaviors.indexOf(b) == nil{
      childBehaviors.append(b)
      b.parentBehavior = self
    }
  }
  
  func play(){
    MotionAnimator.sharedInstance.addAnimation(self)
  }
  
  func stop(){
    MotionAnimator.sharedInstance.removeAnimation(self)
  }
  
  // returning true means require next update(not yet reached target state)
  // behaviors can call animator.addAnimation to wake up the animator when
  // the target value changed
  func update(dt:CGFloat) -> Bool{
    var running = false
    for c in childBehaviors{
      if c.update(dt){
        running = true
      }
    }
    return running
  }
}
