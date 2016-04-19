//
//  ValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-18.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public typealias CGFloatValueGetterBlock = (() -> CGFloat)
public typealias CGFloatValueSetterBlock = ((CGFloat) -> Void)
public class ValueAnimation:MotionAnimation {
  private var getter:CGFloatValueGetterBlock?
  private var setter:CGFloatValueSetterBlock?
  public var target:CGFloat = 0{
    didSet{
      if target != getter?(){
        play()
      }
    }
  }
  public var velocity:CGFloat = 0
  
  public override init() {
    super.init()
  }
  
  public init(getter:CGFloatValueGetterBlock, setter:CGFloatValueSetterBlock, target:CGFloat) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
  }

  public var value:CGFloat = 0

  override public func willUpdate() {
    value = getter?() ?? 0
  }
  override public func didUpdate() {
    setter?(value)
  }
}

public typealias CGFloatValuesGetterBlock = (() -> [CGFloat])
public typealias CGFloatValuesSetterBlock = (([CGFloat]) -> Void)
public typealias ValueAnimationFactory = () -> ValueAnimation
public class MultiValueAnimation:MotionAnimation {
  public var getter:CGFloatValuesGetterBlock?
  public var setter:CGFloatValuesSetterBlock?
  public var target:[CGFloat] = [0]{
    didSet{
      loop { c, i in
        c.target = self.target[i]
      }
      play()
    }
  }
  
  public func loop(cb:((ValueAnimation, Int) -> Void)){
    for (i, c) in (childAnimations as! [ValueAnimation]).enumerate(){
      cb(c, i)
    }
  }
  
  public var velocity:[CGFloat]{
    var velocity:[CGFloat] = []
    velocity.reserveCapacity(childAnimations.count)
    loop { c, i in
      velocity.append(c.velocity)
    }
    return velocity
  }
  
  public var current:[CGFloat] = [0]
  
  public override func update(dt: CGFloat) -> Bool {
    return super.update(dt)
  }
  
  public init(animationFactory:ValueAnimationFactory, getter:CGFloatValuesGetterBlock, setter:CGFloatValuesSetterBlock, target:[CGFloat]) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
    self.current = getter()

    for (i, t) in target.enumerate(){
      let b = animationFactory()
      b.getter = {
        return self.current.count > i ? self.current[i] : 0
      }
      b.setter = {
        if self.current.count > i{
            self.current[i] = $0
        }
      }
      b.target = t
      addChildBehavior(b)
    }
  }

  override public func willUpdate() {
    if let p = getter?(){
      current = p
    }
  }
  override public func didUpdate() {
    super.didUpdate()
    setter?(current)
  }
}
