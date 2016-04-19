//
//  UIView+MotionAnimation.swift
//  MotionAnimationExample
//
//  Created by YiLun Zhao on 2016-02-21.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
@objc public protocol PositionAnimatable{
  var position:CGPoint{get set}
}
public class PositionAnimation:MotionAnimation{
  weak var view:PositionAnimatable?
  init(view:PositionAnimatable) {
    self.view = view
    super.init()
  }
  public var targetPosition = CGPointZero
  public var velocity = CGPointZero
  public var damping:CGPoint = CGPointMake(3, 3)
  public var threshold:CGFloat = 0.1
  public var stiffness:CGPoint = CGPointMake(50, 50)

  func animationToTargetPosition(target:CGPoint){
    targetPosition = target
    play()
  }


  private var position:CGPoint = CGPointZero
  override public func willUpdate() {
    position = view?.position ?? CGPointZero
  }
  override public func didUpdate() {
    view?.position = position
  }
  override public func update(dt:CGFloat) -> Bool{
    // Force
    let Fspring = -stiffness * (position - targetPosition)

    // Damping
    let Fdamper = -damping * velocity;

    let a = Fspring + Fdamper;

    let newV = velocity + a * dt;
    let newPosition = position + newV * dt;

    let lowVelocity = abs(newV.x) < threshold && abs(newV.y) < threshold
    if lowVelocity && abs(targetPosition.x - newPosition.x) < threshold && abs(targetPosition.y - newPosition.y) < threshold {
      velocity = CGPointZero
      position = self.targetPosition
      return false
    } else {
      velocity = newV
      position = newPosition
      return true
    }
  }
}

extension UIView: PositionAnimatable, MotionAnimationDelegate {
  public var position:CGPoint{
    get{
      return center
    }
    set{
      center = newValue
    }
  }

  private struct m_uiview_associatedKeys {
    static var m_centerAnimation = "m_centerAnimation_key"
  }

  public var centerAnimation:PositionAnimation!{
    get {
      if let rtn = objc_getAssociatedObject(self, &m_uiview_associatedKeys.m_centerAnimation) as? PositionAnimation{
        return rtn
      }
      self.centerAnimation = PositionAnimation(view: self)
      self.centerAnimation.delegate = self
      return objc_getAssociatedObject(self, &m_uiview_associatedKeys.m_centerAnimation) as! PositionAnimation
    }
    set {
      objc_setAssociatedObject(
        self,
        &m_uiview_associatedKeys.m_centerAnimation,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  public func animateCenterTo(
    point:CGPoint,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    completion:(() -> Void)? = nil) {
      centerAnimation.onCompletion?(animation:centerAnimation)
      if let threshold = threshold{
        centerAnimation.threshold = threshold
      }
      if let damping = damping{
        centerAnimation.damping = CGPointMake(damping, damping)
      }
      if let stiffness = stiffness{
        centerAnimation.stiffness = CGPointMake(stiffness, stiffness)
      }
      if let completion = completion{
        centerAnimation.onCompletion = { animation in
          animation.onCompletion = nil
          completion()
        }
      }
      centerAnimation.animationToTargetPosition(point)
  }

  public func animationDidPerformStep(animation: MotionAnimation) {

  }

  public func animationDidStop(animation: MotionAnimation) {

  }

  public func stopAllAnimation(){
    centerAnimation.stop()
  }
}
