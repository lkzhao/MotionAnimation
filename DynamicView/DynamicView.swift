//
//  DynamicView.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-16.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


extension NSTimer {
  /**
   Creates and schedules a one-time `NSTimer` instance.
   
   - Parameters:
   - delay: The delay before execution.
   - handler: A closure to execute after `delay`.
   
   - Returns: The newly-created `NSTimer` instance.
   */
  class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
    let fireDate = delay + CFAbsoluteTimeGetCurrent()
    let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
    return timer
  }
  
  /**
   Creates and schedules a repeating `NSTimer` instance.
   
   - Parameters:
   - repeatInterval: The interval (in seconds) between each execution of
   `handler`. Note that individual calls may be delayed; subsequent calls
   to `handler` will be based on the time the timer was created.
   - handler: A closure to execute at each `repeatInterval`.
   
   - Returns: The newly-created `NSTimer` instance.
   */
  class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
    let fireDate = interval + CFAbsoluteTimeGetCurrent()
    let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
    return timer
  }
}



// a high accuracy version of UIAttachmentBehavior. eliminate wobble bug with UIAttachmentBehavior.
class LKAttachmentBehavior:UIDynamicBehavior {
  var ab1:UIAttachmentBehavior!
  var ab2:UIAttachmentBehavior!
  var ab3:UIAttachmentBehavior!
  var ab4:UIAttachmentBehavior!
  var highAccuracy:Bool{
    return ab2 != nil
  }
  
  var item:UIDynamicItem
  var length:CGFloat = 500

  var frequency:CGFloat = 1{
    didSet{
      ab1.frequency = frequency
      if highAccuracy{
        ab2.frequency = frequency
        ab3.frequency = frequency
        ab4.frequency = frequency
      }
    }
  }
  var damping:CGFloat = 0{
    didSet{
      ab1.damping = damping
      if highAccuracy{
        ab2.damping = damping
        ab3.damping = damping
        ab4.damping = damping
      }
    }
  }
  var anchorPoint:CGPoint{
    didSet{
      updatePoints()
    }
  }
  func updatePoints(){
    if highAccuracy{
      ab1.anchorPoint = anchorPoint.translate(length, dy: 0)
      ab2.anchorPoint = anchorPoint.translate(-length, dy: 0)
      ab3.anchorPoint = anchorPoint.translate(0, dy: length)
      ab4.anchorPoint = anchorPoint.translate(0, dy: -length)
    }else{
      ab1.anchorPoint = anchorPoint
    }
  }
  
  init(item:UIDynamicItem, attachedToAnchor anchorPoint:CGPoint, highAccuracy:Bool = true) {
    self.item = item
    self.anchorPoint = anchorPoint
    super.init()
    
    ab1 = UIAttachmentBehavior(item: item, attachedToAnchor: anchorPoint)
    addChildBehavior(ab1)
    ab1.length = 0
    if highAccuracy{
      ab2 = UIAttachmentBehavior(item: item, attachedToAnchor: anchorPoint)
      addChildBehavior(ab2)
      ab3 = UIAttachmentBehavior(item: item, attachedToAnchor: anchorPoint)
      addChildBehavior(ab3)
      ab4 = UIAttachmentBehavior(item: item, attachedToAnchor: anchorPoint)
      addChildBehavior(ab4)
      ab2.length = length
      ab3.length = length
      ab4.length = length
      ab1.length = length
    }
    updatePoints()
  }
}

class DynamicItem:NSObject, UIDynamicItem{
  var center: CGPoint = CGPointZero
  var bounds: CGRect = CGRectMake(0, 0, 1, 1)
  var transform: CGAffineTransform = CGAffineTransformIdentity
  init(center:CGPoint) {
    self.center = center
    super.init()
  }
}

class DynamicValue{
  var valueBehavior:LKAttachmentBehavior!
  var valueItem:DynamicItem!
  var currentValue:CGPoint{
    get{
      return valueItem.center
    }
    set{
      valueItem.center = newValue
    }
  }
  var targetValue:CGPoint{
    get{
      return valueBehavior.anchorPoint
    }
    set{
      valueBehavior.anchorPoint = newValue
      if valueBehavior.dynamicAnimator == nil{
        currentValue = newValue
        updateValueBlock(value: newValue)
      }
    }
  }
  var updateValueBlock:(value:CGPoint) -> Void
  init(value:CGPoint, highAccuracy:Bool = true, updateValueBlock:(value:CGPoint) -> Void){
    self.updateValueBlock = updateValueBlock
    
    valueItem = DynamicItem(center: value)
    valueBehavior = LKAttachmentBehavior(item: valueItem, attachedToAnchor: value, highAccuracy: highAccuracy)
    valueBehavior.frequency = 2
    valueBehavior.damping = 0.2
    valueBehavior.action = {
      self.updateValueBlock(value: self.currentValue)
    }
  }
  convenience init(value1:CGFloat, value2:CGFloat, highAccuracy:Bool = true, updateValueBlock:(value1:CGFloat, value2:CGFloat) -> Void){
    self.init(value:CGPointMake(value1, value2), highAccuracy:highAccuracy){ (value) in
      updateValueBlock(value1: value.x, value2: value.y)
    }
  }
}

class DynamicView: UIView {
  private var manuallyDisabledAnimation = false
  var animationEnabled = false{
    didSet{
      if !animationEnabled{
        manuallyDisabledAnimation = true
        dynamicAnimator.removeAllBehaviors()
      }else{
        for dynamicValue in dynamicValues{
          dynamicAnimator.addBehavior(dynamicValue.valueBehavior)
        }
      }
    }
  }
  var movementRotationEnabled = true
  var dynamicValues:[DynamicValue] = []
  var damping:CGFloat = 0.2
  
  var dynamicAnimator = UIDynamicAnimator()
  
  // dynamicValues
  var centerDynamicValue:DynamicValue!
  var zHeightDynamicValue:DynamicValue!
  var cornerRadiusDynamicValue:DynamicValue!
  var scaleDynamicValue:DynamicValue!
  var alphaDynamicValue:DynamicValue!
  var sizeDynamicValue:DynamicValue!
  
  // center
  var dynamicCenter:CGPoint{
    get{
      return centerDynamicValue.targetValue
    }
    set{
      centerDynamicValue.targetValue = newValue
    }
  }
  // zHeight
  var dynamiczHeight:CGFloat{
    get{
      return zHeightDynamicValue.targetValue.x
    }
    set{
      zHeightDynamicValue.targetValue = CGPointMake(newValue, 0)
    }
  }
  // alpha
  var dynamicAlpha:CGFloat{
    get{
      return alphaDynamicValue.targetValue.x
    }
    set{
      alphaDynamicValue.targetValue = CGPointMake(newValue, 0)
    }
  }
  // scale
  var dynamicScale:CGFloat{
    get{
      return scaleDynamicValue.targetValue.x
    }
    set{
      scaleDynamicValue.targetValue = CGPointMake(newValue, 0)
    }
  }
  // cornerRadius
  var dynamicCornerRadius:CGFloat{
    get{
      return cornerRadiusDynamicValue.targetValue.x
    }
    set{
      cornerRadiusDynamicValue.targetValue = CGPointMake(newValue, 0)
    }
  }
  // size
  var dynamicSize:CGSize{
    get{
      return CGSizeMake(sizeDynamicValue.targetValue.x, sizeDynamicValue.targetValue.y)
    }
    set{
      sizeDynamicValue.targetValue = CGPointMake(newValue.width, newValue.height)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  private func setup(){
    centerDynamicValue = DynamicValue(value:center) { (center) -> Void in
      self.center = center
      self.updateTransform()
    }
    centerDynamicValue.valueBehavior.damping = 1.0
    centerDynamicValue.valueBehavior.frequency = 4
    
    zHeightDynamicValue = DynamicValue(value1:0, value2:0, highAccuracy: false) { (zHeight, _) -> Void in

    }
    zHeightDynamicValue.valueBehavior.damping = 0.7
    centerDynamicValue.valueBehavior.frequency = 3
    
    alphaDynamicValue = DynamicValue(value1:1, value2:0, highAccuracy: true) { (alpha, _) -> Void in
      self.alpha = alpha
    }
    alphaDynamicValue.valueBehavior.damping = 1.0
    alphaDynamicValue.valueBehavior.frequency = 4
    
    scaleDynamicValue = DynamicValue(value1:1000, value2:0, highAccuracy: false) { (cornerRadius, _) -> Void in
    }
    scaleDynamicValue.valueBehavior.damping = 1.0
    scaleDynamicValue.valueBehavior.frequency = 4
    
    cornerRadiusDynamicValue = DynamicValue(value1:0, value2:0, highAccuracy: false) { (cornerRadius, _) -> Void in
      self.layer.cornerRadius = cornerRadius
    }
    cornerRadiusDynamicValue.valueBehavior.damping = 1.0
    cornerRadiusDynamicValue.valueBehavior.frequency = 4

    sizeDynamicValue = DynamicValue(value1:bounds.size.width, value2:bounds.size.height) { (width, height) -> Void in
      self.bounds.size = CGSizeMake(width, height)
    }
    sizeDynamicValue.valueBehavior.damping = 1.0
    sizeDynamicValue.valueBehavior.frequency = 4
    
    dynamicValues = [alphaDynamicValue, centerDynamicValue, scaleDynamicValue, cornerRadiusDynamicValue, zHeightDynamicValue, sizeDynamicValue]
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    if !manuallyDisabledAnimation{
      animationEnabled = true
    }
  }
  
  func updateTransform(){
    var t = CATransform3DMakeScale(scaleDynamicValue.currentValue.x/1000, scaleDynamicValue.currentValue.x/1000, 1)
    if movementRotationEnabled{
      let rotation = (dynamicCenter - center) / 500
      t.m34 = 1.0 / -500
      t = CATransform3DRotate(t, -rotation.x, 0.0, 1.0, 0.0)
      t = CATransform3DRotate(t, rotation.y, 1.0, 0.0, 0.0)
    }
    layer.transform = t
  }
}
