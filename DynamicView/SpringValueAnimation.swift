//
//  SpringValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


typealias CGFloatValueGetterBlock = (() -> CGFloat)
typealias CGFloatValueSetterBlock = ((CGFloat) -> Void)
class SpringValueAnimation:MotionAnimation {
  var getter:CGFloatValueGetterBlock?
  var setter:CGFloatValueSetterBlock?
  var target:CGFloat = 0{
    didSet{ play() }
  }
  
  var errorMargin:CGFloat = 0.01
  var k:CGFloat = 150
  var b:CGFloat = 11
  
  var v:CGFloat = 0
  func shouldStop(x:CGFloat) -> Bool{
    return abs(v) < errorMargin && abs(target - x) < errorMargin
  }
  
  init(getter:CGFloatValueGetterBlock, setter:CGFloatValueSetterBlock, target:CGFloat) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
  }
  
  //from https://github.com/chenglou/react-motion
  override func update(dt:CGFloat) -> Bool{
    // Force
    let x = getter?() ?? 0
    let Fspring = -k * (x - target);
    
    // Damping
    let Fdamper = -b * v;
    
    let a = Fspring + Fdamper;
    
    let newV = v + a * dt;
    let newX = x + newV * dt;
    
    if shouldStop(newX) {
      setter?(target)
      v = 0
      return false
    }else{
      setter?(newX)
      v = newV
      return true
    }
  }
}


typealias CGFloatValuesGetterBlock = (() -> [CGFloat])
typealias CGFloatValuesSetterBlock = (([CGFloat]) -> Void)
class SpringMultiValueAnimation:MotionAnimation {
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
  
  var firstStringBehavior:SpringValueAnimation{
    return childBehaviors.first! as! SpringValueAnimation
  }
  var errorMargin:CGFloat{
    get{
      return firstStringBehavior.errorMargin
    }
    set{
      loop { b, i in
        b.errorMargin = newValue
      }
    }
  }
  var k:CGFloat{
    get{
      return firstStringBehavior.k
    }
    set{
      loop { b, i in
        b.k = newValue
      }
    }
  }
  var b:CGFloat{
    get{
      return firstStringBehavior.b
    }
    set{
      loop { b, i in
        b.b = newValue
      }
    }
  }
  
  func loop(cb:((SpringValueAnimation, Int) -> Void)){
    for (i, c) in (childBehaviors as! [SpringValueAnimation]).enumerate(){
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
  
  init(getter:CGFloatValuesGetterBlock, setter:CGFloatValuesSetterBlock, target:[CGFloat]) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
    
    for (i, t) in target.enumerate(){
      let b = SpringValueAnimation(getter: { () -> CGFloat in
        return self.current[i]
        }, setter: { (newValue) -> Void in
          self.current[i] = newValue
        }, target: t)
      addChildBehavior(b)
    }
  }
}
