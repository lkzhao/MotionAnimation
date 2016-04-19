//
//  SpringValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


public class SpringValueAnimation:ValueAnimation {
  public var threshold:CGFloat = 0.001
  public var stiffness:CGFloat = 150
  public var damping:CGFloat = 10

  //from https://github.com/chenglou/react-motion
  public override func update(dt:CGFloat) -> Bool{
    // Force
    let Fspring = -stiffness * (value - target);
    
    // Damping
    let Fdamper = -damping * velocity;
    
    let a = Fspring + Fdamper;
    
    let newV = velocity + a * dt;
    let newX = value + newV * dt;
    
    if abs(velocity) < threshold && abs(target - newX) < threshold {
      value = target
      velocity = 0
      return false
    }else{
      value = newX
      velocity = newV
      return true
    }
  }
}