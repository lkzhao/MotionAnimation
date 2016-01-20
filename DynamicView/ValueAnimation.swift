//
//  ValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-18.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

typealias CGFloatValueGetterBlock = (() -> CGFloat)
typealias CGFloatValueSetterBlock = ((CGFloat) -> Void)
class ValueAnimation:MotionAnimation {
  var getter:CGFloatValueGetterBlock?
  var setter:CGFloatValueSetterBlock?
  var target:CGFloat = 0{
    didSet{
      if target != getter?(){
        play()
      }
    }
  }
  
  override init() {
    super.init()
  }
  
  init(getter:CGFloatValueGetterBlock, setter:CGFloatValueSetterBlock, target:CGFloat) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
  }
}

typealias CGFloatValuesGetterBlock = (() -> [CGFloat])
typealias CGFloatValuesSetterBlock = (([CGFloat]) -> Void)
typealias ValueAnimationFactory = () -> ValueAnimation
class MultiValueAnimation:MotionAnimation {
  var getter:CGFloatValuesGetterBlock?
  var setter:CGFloatValuesSetterBlock?
  var target:[CGFloat] = [0]{
    didSet{
      loop { c, i in
        c.target = self.target[i]
      }
      play()
    }
  }
  
  func loop(cb:((ValueAnimation, Int) -> Void)){
    for (i, c) in (childAnimations as! [ValueAnimation]).enumerate(){
      cb(c, i)
    }
  }
  
  var current:[CGFloat] = [0]
  
  override func update(dt: CGFloat) -> Bool {
    if let p = getter?(){
      current = p
    }
    let running = super.update(dt)
    setter?(current)
    return running
  }
  
  init(animationFactory:ValueAnimationFactory, getter:CGFloatValuesGetterBlock, setter:CGFloatValuesSetterBlock, target:[CGFloat]) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
    self.current = getter()

    for (i, t) in target.enumerate(){
      let b = animationFactory()
      b.getter = {
        return self.current[i]
      }
      b.setter = {
        self.current[i] = $0
      }
      b.target = t
      addChildBehavior(b)
    }
  }
}
