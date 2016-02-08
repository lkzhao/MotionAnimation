//
//  NSObject+MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public extension NSObject{
  private struct m_associatedKeys {
    static var m_propertyStates = "m_propertyStates_key"
  }
  private var m_propertyStates:[String:MotionAnimationPropertyState]{
    get {
      if let rtn = objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as? [String:MotionAnimationPropertyState]{
        return rtn
      }
      self.m_propertyStates = [:]
      return objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as! [String:MotionAnimationPropertyState]
    }
    set {
      objc_setAssociatedObject(
        self,
        &m_associatedKeys.m_propertyStates,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  
  private func getPropertyState(key:String) -> MotionAnimationPropertyState{
    if m_propertyStates[key] == nil {
      m_propertyStates[key] = MotionAnimationPropertyState(obj: self, keyPath: key)
    }
    return m_propertyStates[key]!
  }
  
  // define custom animatable property
  func m_setValues(values:[CGFloat], forCustomProperty key:String){
    getPropertyState(key).setValues(values)
  }
  func m_defineCustomProperty(key:String, initialValues:[CGFloat], valueUpdateCallback:CGFloatValuesSetterBlock){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(values: initialValues)
    getPropertyState(key).addValueUpdateCallback(.CGFloatMultiObserver(valueUpdateCallback))
  }
  
  // add callbacks
  func m_addValueUpdateCallback(key:String, valueUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    return getPropertyState(key).addValueUpdateCallback(valueUpdateCallback)
  }
  func m_addVelocityUpdateCallback(key:String, velocityUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    return getPropertyState(key).addVelocityUpdateCallback(velocityUpdateCallback)
  }
  func m_removeCallback(key:String, observerKey:MotionAnimationValueObserverKey){
    getPropertyState(key).removeCallback(observerKey)
  }
  
  // animation
  func m_delay(time:NSTimeInterval, completion:(() -> Void)){
    NSTimer.schedule(delay: time) { timer in
      completion()
    }
  }
  func m_animate(
    key:String,
    to:UIColor,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.UIColorValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:CGFloat,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGFloatValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:[CGFloat],
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGFloatMultiValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:CGRect,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGRectValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:CGPoint,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGPointValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:MotionAnimationValue,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(to, stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
}