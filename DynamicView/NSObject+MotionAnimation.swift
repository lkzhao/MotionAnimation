//
//  NSObject+MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


private class MotionCustomProperty{
  var updateCallback:CGFloatValuesSetterBlock?
  var value:[CGFloat] = [0]{
    didSet{
      updateCallback?(value)
    }
  }
  init(value:[CGFloat], updateCallback:CGFloatValuesSetterBlock){
    self.value = value
    self.updateCallback = updateCallback
    updateCallback(value)
  }
}


extension NSObject{
  private struct m_associatedKeys {
    static var m_animations = "m_animations_key"
    static var m_customProperties = "m_customProperties_key"
  }
  private var m_animations:[String:MotionAnimation]?{
    get {
      return objc_getAssociatedObject(self, &m_associatedKeys.m_animations) as? [String:MotionAnimation]
    }
    set {
      objc_setAssociatedObject(
        self,
        &m_associatedKeys.m_animations,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  private var m_customProperties:[String:MotionCustomProperty]?{
    get {
      return objc_getAssociatedObject(self, &m_associatedKeys.m_customProperties) as? [String:MotionCustomProperty]
    }
    set {
      objc_setAssociatedObject(
        self,
        &m_associatedKeys.m_customProperties,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  
  
  func m_addAnimation(key:String, animation:MotionAnimation){
    if m_animations != nil{
      m_animations![key] = animation
    }else{
      m_animations = [:]
      m_animations![key] = animation
    }
  }
  func m_animationForKey(key:String) -> MotionAnimation?{
    if m_animations != nil{
      return m_animations![key]
    }
    return nil
  }
  func m_removeAnimationForKey(key:String){
    if m_animations != nil{
      m_animations!.removeValueForKey(key)
    }
  }
  func m_removeAllAnimation(){
    if let m_animations = m_animations{
      for (k, v) in m_animations{
        v.stop()
      }
    }
    m_animations = nil
  }
  
  func m_setValue(value:[CGFloat], forCustomProperty key:String){
    if m_customProperties != nil {
      if let customProperty = m_customProperties![key]{
        customProperty.value = value
      }else{
        fatalError("Custom property \(key) not defined")
      }
    }
  }
  func m_getValueForCustomProperty(key:String) -> [CGFloat]?{
    return m_getCustomProperty(key)?.value
  }
  private func m_getCustomProperty(key:String) -> MotionCustomProperty?{
    if m_customProperties != nil {
      return m_customProperties![key]
    }
    return nil
  }
  func m_defineCustomProperty(key:String, initialValue:[CGFloat], valueUpdateCallback:CGFloatValuesSetterBlock){
    if m_customProperties != nil {
      m_customProperties![key] = MotionCustomProperty(value: initialValue, updateCallback: valueUpdateCallback)
    }else{
      m_customProperties = [key: MotionCustomProperty(value: initialValue, updateCallback: valueUpdateCallback)]
    }
  }
  
  func m_animate(key:String, toValue:CGFloat, stiffness:CGFloat? = nil, damping:CGFloat? = nil, threshold:CGFloat? = nil,onUpdate:((CGFloat) -> Void)? = nil,completion:(() -> Void)? = nil){
    var wrappedOnUpdate:(([CGFloat]) -> Void)? = nil
    if let onUpdate = onUpdate{
      wrappedOnUpdate = { velocity in
        onUpdate(velocity[0])
      }
    }
    self.m_animate(key,
      toValues: [toValue],
      stiffness: stiffness,
      damping: damping,
      getter: {
        return [CGFloat(self.valueForKeyPath(key)!.floatValue)]
      },
      setter: {
        self.setValue($0[0], forKeyPath: key)
      },
      onUpdate: wrappedOnUpdate,
      completion: completion)
  }

  func m_animate(key:String, toPoint:CGPoint, stiffness:CGFloat? = nil, damping:CGFloat? = nil, threshold:CGFloat? = nil,onUpdate:((CGPoint) -> Void)? = nil,completion:(() -> Void)? = nil){
    var wrappedOnUpdate:(([CGFloat]) -> Void)? = nil
    if let onUpdate = onUpdate{
      wrappedOnUpdate = { velocity in
        onUpdate(CGPointMake(velocity[0], velocity[1]))
      }
    }
    self.m_animate(key,
      toValues: [toPoint.x, toPoint.y],
      stiffness: stiffness,
      damping: damping,
      getter: {
        let p = self.valueForKeyPath(key)!.CGPointValue
        return [p.x, p.y]
      }, setter: {
        self.setValue(NSValue(CGPoint: CGPointMake($0[0], $0[1])), forKeyPath: key)
      },
      onUpdate: wrappedOnUpdate,
      completion: completion)
  }

  func m_animate(key:String, toRect:CGRect, stiffness:CGFloat? = nil, damping:CGFloat? = nil, threshold:CGFloat? = nil,onUpdate:((CGRect) -> Void)? = nil,completion:(() -> Void)? = nil){
    var wrappedOnUpdate:(([CGFloat]) -> Void)? = nil
    if let onUpdate = onUpdate{
      wrappedOnUpdate = { velocity in
        onUpdate(CGRectMake(velocity[0], velocity[1], velocity[2], velocity[3]))
      }
    }
    self.m_animate(key,
      toValues: [toRect.origin.x, toRect.origin.y, toRect.width, toRect.height],
      stiffness: stiffness,
      damping: damping,
      getter: {
        let p = self.valueForKeyPath(key)!.CGRectValue
        return [p.origin.x, p.origin.y, p.width, p.height]
      }, setter: {
        self.setValue(NSValue(CGRect: CGRectMake($0[0], $0[1], $0[2], $0[3])), forKeyPath: key)
      },
      onUpdate: wrappedOnUpdate,
      completion: completion)
  }
  
  func m_animate(key:String, toValues:[CGFloat], stiffness:CGFloat? = nil, damping:CGFloat? = nil, threshold:CGFloat? = nil, getter:CGFloatValuesGetterBlock? = nil, setter:CGFloatValuesSetterBlock? = nil, onUpdate:(([CGFloat]) -> Void)? = nil, completion:(() -> Void)? = nil){
    let anim:MultiValueAnimation
    if let existingAnim = m_animationForKey(key) as? MultiValueAnimation{
      anim = existingAnim
      if damping != nil || stiffness != nil{
        anim.loop{ childAnimation, i in
          if let spring = childAnimation as? SpringValueAnimation{
            spring.damping = damping ?? spring.damping
            spring.stiffness = stiffness ?? spring.stiffness
            spring.threshold = threshold ?? spring.threshold
          }
        }
      }
      anim.target = toValues
    }else{
      anim = MultiValueAnimation(animationFactory:{
          let spring = SpringValueAnimation()
          spring.damping = damping ?? spring.damping
          spring.stiffness = stiffness ?? spring.stiffness
          spring.threshold = threshold ?? spring.threshold
          return spring
        },
        getter: {
          if let value = self.m_getValueForCustomProperty(key){
            return value
          }else if let getter = getter{
            return getter()
          }else{
            return self.valueForKeyPath(key)! as! [CGFloat]
          }
        }, setter: { newValues in
          if let cp = self.m_getCustomProperty(key){
            cp.value = newValues
          }else if let setter = setter{
            setter(newValues)
          }else{
            self.setValue(newValues, forKeyPath: key)
          }
        }, target: toValues)
      
      m_removeAnimationForKey(key)
      m_addAnimation(key, animation: anim)
    }
    if let onUpdate = onUpdate{
      anim.onUpdate = { a in
        onUpdate(anim.velocity)
      }
    }else{
      anim.onUpdate = nil
    }
    if let completion = completion{
      anim.onCompletion = { anim in
        completion()
      }
    }else{
      anim.onCompletion = nil
    }
  }
}