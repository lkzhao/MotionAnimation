//
//  NSObject+MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

typealias MotionAnimationValueObserverKey = NSUUID

enum MotionAnimationValueObserver{
  case CGFloatObserver((CGFloat) -> Void)
  case CGRectObserver((CGRect) -> Void)
  case CGPointObserver((CGPoint) -> Void)
  case CGFloatMultiObserver(([CGFloat]) -> Void)
  
  var valueType:MotionAnimationValueType{
    switch self{
    case .CGFloatObserver:
      return .CGFloatValue
    case .CGRectObserver:
      return .CGRectValue
    case .CGPointObserver:
      return .CGPointValue
    case .CGFloatMultiObserver:
      return .CGFloatMultiValue
    }
  }
  
  func executeWithValues(values:[CGFloat]){
    switch self{
    case .CGFloatObserver(let cb):
      cb(values[0])
    case .CGPointObserver(let cb):
      cb(CGPointMake(values[0],values[1]))
    case .CGRectObserver(let cb):
      cb(CGRectMake(values[0],values[1],values[2],values[3]))
    case .CGFloatMultiObserver(let cb):
      cb(values)
    }
  }
}

enum MotionAnimationValueType{
  case CGFloatValue
  case CGRectValue
  case CGPointValue
  case CGFloatMultiValue
}
enum MotionAnimationValue{
  case CGFloatValue(CGFloat)
  case CGRectValue(CGRect)
  case CGPointValue(CGPoint)
  case CGFloatMultiValue([CGFloat])
  
  static func valueFromValues(values:[CGFloat], withType type:MotionAnimationValueType) -> MotionAnimationValue{
    switch type{
    case .CGFloatValue:
      return .CGFloatValue(values[0])
    case .CGRectValue:
      return .CGRectValue(CGRectMake(values[0],values[1],values[2],values[3]))
    case .CGPointValue:
      return .CGPointValue(CGPointMake(values[0],values[1]))
    case .CGFloatMultiValue:
      return .CGFloatMultiValue(values)
    }
  }
  var type:MotionAnimationValueType{
    switch self{
    case .CGFloatValue:
      return .CGFloatValue
    case .CGRectValue:
      return .CGRectValue
    case .CGPointValue:
      return .CGPointValue
    case .CGFloatMultiValue:
      return .CGFloatMultiValue
    }
  }
  func getCGFloatValues() -> [CGFloat]{
    switch self{
    case .CGFloatValue(let v):
      return [v]
    case .CGRectValue(let v):
      return [v.origin.x, v.origin.y, v.width, v.height]
    case .CGPointValue(let v):
      return [v.x, v.y]
    case .CGFloatMultiValue(let v):
      return v
    }
  }
  func getValue() -> AnyObject{
    switch self{
    case .CGFloatValue(let v):
      return v
    case .CGRectValue(let v):
      return NSValue(CGRect: v)
    case .CGPointValue(let v):
      return NSValue(CGPoint: v)
    case .CGFloatMultiValue(let v):
      return v
    }
  }
}

typealias MotionAnimationVelocityObserver = MotionAnimationValueObserver


private class MotionCustomProperty: MotionAnimationDelegate{
  private enum ValueStore{
    case ObjectKeyPath(obj:NSObject, keyPath:String)
    case Values(values:[CGFloat])
    func valuesForType(type:MotionAnimationValueType) -> [CGFloat]{
      switch self{
      case .ObjectKeyPath(let obj, let keyPath):
        let v = obj.valueForKeyPath(keyPath)!
        switch type{
        case .CGFloatValue:
          return MotionAnimationValue.CGFloatValue(CGFloat(v.floatValue)).getCGFloatValues()
        case .CGRectValue:
          return MotionAnimationValue.CGRectValue(v.CGRectValue).getCGFloatValues()
        case .CGPointValue:
          return MotionAnimationValue.CGPointValue(v.CGPointValue).getCGFloatValues()
        case .CGFloatMultiValue:
          return v as! [CGFloat]
        }
      case .Values(let values):
        return values
      }
    }
    mutating func setValue(value:MotionAnimationValue){
      switch self{
      case .ObjectKeyPath(let obj, let keyPath):
        obj.setValue(value.getValue(), forKey: keyPath)
      case .Values:
        self = .Values(values: value.getCGFloatValues())
      }
    }
  }
  var velocityUpdateCallbacks:[NSUUID:MotionAnimationVelocityObserver] = [:]
  var valueUpdateCallbacks:[NSUUID:MotionAnimationValueObserver] = [:]
  
  var animation:MotionAnimation?
  
  private var _objectKeyPath:(NSObject, String)?
  private var valueStore:ValueStore
  
  init(values:[CGFloat]){
    valueStore = .Values(values: values)
  }
  
  init(obj:NSObject, keyPath:String){
    valueStore = .ObjectKeyPath(obj: obj, keyPath: keyPath)
  }
  
  private var _tempVelocityUpdate: MotionAnimationVelocityObserver?
  private var _tempValueUpdate: MotionAnimationValueObserver?
  private var _tempCompletion: (() -> Void)?
  func animate(
    toValues:MotionAnimationValue,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      
      let anim:MultiValueAnimation
      if let animation = animation as? MultiValueAnimation{
        anim = animation
        if damping != nil || stiffness != nil || threshold != nil{
          anim.loop{ childAnimation, i in
            if let spring = childAnimation as? SpringValueAnimation{
              spring.damping = damping ?? spring.damping
              spring.stiffness = stiffness ?? spring.stiffness
              spring.threshold = threshold ?? spring.threshold
            }
          }
        }
      }else{
        animation?.stop()
        anim = MultiValueAnimation(animationFactory: {
          let spring = SpringValueAnimation()
          spring.damping = damping ?? spring.damping
          spring.stiffness = stiffness ?? spring.stiffness
          spring.threshold = threshold ?? spring.threshold
          return spring
          }, getter: {
            return self.valueStore.valuesForType(toValues.type)
          }, setter: { newValues in
            self.valueStore.setValue(MotionAnimationValue.valueFromValues(newValues, withType: toValues.type))
          }, target: toValues.getCGFloatValues())
        animation = anim
      }
      _tempVelocityUpdate = velocityUpdate
      _tempValueUpdate = valueUpdate
      _tempCompletion = completion
      anim.delegate = self
      anim.target = toValues.getCGFloatValues()
  }
  
  func addVelocityUpdateCallback(velocityUpdateCallback:MotionAnimationVelocityObserver) -> MotionAnimationValueObserverKey{
    let uuid = NSUUID()
    self.velocityUpdateCallbacks[uuid] = velocityUpdateCallback
    return uuid
  }
  
  func addValueUpdateCallback(valueUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationValueObserverKey{
    let uuid = NSUUID()
    self.valueUpdateCallbacks[uuid] = valueUpdateCallback
    return uuid
  }
  
  func removeCallback(key:MotionAnimationValueObserverKey) -> MotionAnimationValueObserver? {
    return self.valueUpdateCallbacks.removeValueForKey(key) ?? self.velocityUpdateCallbacks.removeValueForKey(key)
  }
  
  private func animationDidStop(animation:MotionAnimation){
    _tempValueUpdate = nil
    _tempVelocityUpdate = nil
    if let _tempCompletion = _tempCompletion{
      self._tempCompletion = nil
      _tempCompletion()
    }
  }
  
  private func animationDidPerformStep(animation:MotionAnimation){
    if velocityUpdateCallbacks.count > 0 || _tempVelocityUpdate != nil{
      let v = (animation as! MultiValueAnimation).velocity
      for (_, callback) in velocityUpdateCallbacks{
        callback.executeWithValues(v)
      }
      _tempVelocityUpdate?.executeWithValues(v)
    }
    for (_, callback) in valueUpdateCallbacks{
      callback.executeWithValues(valueStore.valuesForType(callback.valueType))
    }
    if let _tempValueUpdate = _tempValueUpdate{
      _tempValueUpdate.executeWithValues(valueStore.valuesForType(_tempValueUpdate.valueType))
    }
  }
}


extension NSObject{
  private struct m_associatedKeys {
    static var m_customProperties = "m_customProperties_key"
  }
  private var m_customProperties:[String:MotionCustomProperty]{
    get {
      if let rtn = objc_getAssociatedObject(self, &m_associatedKeys.m_customProperties) as? [String:MotionCustomProperty]{
        return rtn
      }
      self.m_customProperties = [:]
      return objc_getAssociatedObject(self, &m_associatedKeys.m_customProperties) as! [String:MotionCustomProperty]
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
  
  
  private func getCustomProperty(key:String) -> MotionCustomProperty{
    if m_customProperties[key] == nil {
      m_customProperties[key] = MotionCustomProperty(obj: self, keyPath: key)
    }
    return m_customProperties[key]!
  }
  
  //  func m_setValues(values:[CGFloat], forKey key:String){
  //    getCustomProperty(key).values = values
  //  }
  //  func m_getValueForCustomProperty(key:String) -> [CGFloat]?{
  //    return getCustomProperty(key).values
  //  }
  func m_defineCustomProperty(key:String, initialValues:[CGFloat], valueUpdateCallback:CGFloatValuesSetterBlock){
    m_customProperties[key] = MotionCustomProperty(values: initialValues)
    getCustomProperty(key).addValueUpdateCallback(.CGFloatMultiObserver(valueUpdateCallback))
  }
  
  func m_addValueUpdateCallback(key:String, valueUpdateCallback:MotionAnimationValueObserver){
    getCustomProperty(key).addValueUpdateCallback(valueUpdateCallback)
  }
  func m_addVelocityUpdateCallback(key:String, velocityUpdateCallback:MotionAnimationValueObserver){
    getCustomProperty(key).addVelocityUpdateCallback(velocityUpdateCallback)
  }
  func m_delay(time:NSTimeInterval, completion:(() -> Void)){
    NSTimer.schedule(delay: time) { timer in
      completion()
    }
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
      getCustomProperty(key).animate(.CGFloatMultiValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
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
      getCustomProperty(key).animate(.CGPointValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
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
      getCustomProperty(key).animate(to, stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
}