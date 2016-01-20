//
//  SpringValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


class SpringValueAnimation:ValueAnimation {
  var errorMargin:CGFloat = 1
  var stiffness:CGFloat = 120
  var damping:CGFloat = 20
  
  var velocity:CGFloat = 0
  
  //from https://github.com/chenglou/react-motion
  override func update(dt:CGFloat) -> Bool{
    let x = getter?() ?? 0

    if abs(velocity) < errorMargin && abs(target - x) < errorMargin {
      return false
    }

    // Force
    let Fspring = -stiffness * (x - target);
    
    // Damping
    let Fdamper = -damping * velocity;
    
    let a = Fspring + Fdamper;
    
    let newV = velocity + a * dt;
    let newX = x + newV * dt;
    
    if abs(velocity) < errorMargin && abs(target - newX) < errorMargin {
      setter?(target)
      velocity = 0
      return false
    }else{
      setter?(newX)
      velocity = newV
      return true
    }
  }
}