//
//  Types.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-22.
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
  
  static func valueFromCGFloatValues(values:[CGFloat], withType type:MotionAnimationValueType) -> MotionAnimationValue{
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
  static func valueFromRawValue(value:AnyObject, withType type:MotionAnimationValueType) -> MotionAnimationValue{
    switch type{
    case .CGFloatValue:
      return MotionAnimationValue.CGFloatValue(CGFloat(value.floatValue!))
    case .CGRectValue:
      return MotionAnimationValue.CGRectValue(value.CGRectValue!)
    case .CGPointValue:
      return MotionAnimationValue.CGPointValue(value.CGPointValue)
    case .CGFloatMultiValue:
      return .CGFloatMultiValue(value as! [CGFloat])
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
  func rawValue() -> AnyObject{
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
