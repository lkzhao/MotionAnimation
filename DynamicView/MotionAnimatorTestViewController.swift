//
//  MotionAnimatorTestViewController.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

let π = CGFloat(M_PI)

class MotionAnimatorTestViewController: UIViewController {

  var v:UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1.0, alpha: 1)
    v = UIView(frame: CGRectMake(-150,view.center.y-75,150,150))
    v.layer.cornerRadius = 10
    v.backgroundColor = UIColor.whiteColor()
    view.addSubview(v)
    
    MotionAnimator.sharedInstance.debugEnabled = true
    v.m_animate("center", toPoint:view.center, threshold: 1)
    v.m_defineCustomProperty("xy_rotation", initialValue: [0,0], valueUpdateCallback: { (newValues) -> Void in
      var t = CATransform3DMakeRotation(newValues[0], 1.0, 0, 0)
      t = CATransform3DRotate(t, newValues[1], 0, 1.0, 0)
      self.v.layer.transform = t
      let k = Float((newValues[0] + newValues[1]) / π)
      self.v.layer.opacity = 1 - k
    })
    
    let pan = UIPanGestureRecognizer(target: self, action: "pan:")
    v.addGestureRecognizer(pan)

    let tap = UITapGestureRecognizer(target: self, action: "tap:")
    view.addGestureRecognizer(tap)

//    NSTimer.schedule(repeatInterval: 0.5) { (_) -> Void in
//      self.testLoop()
//    }
    testChainingAnimation()
//    testCustomPropertyAnimation()
  }
  
  var usingPointA = false
  func testLoop(){
    let p = usingPointA ? CGPointMake(0,0):view.center
    v.m_animate("center", toPoint: p)
    usingPointA = !usingPointA
  }
  func testChainingAnimation(){
    self.v.m_animate("center", toPoint: CGPointMake(255,255)) {
      print("moved to 255,255")
      self.v.m_animate("center", toPoint: CGPointMake(100,100)) {
        print("moved to 100,100")
        self.v.m_animate("center", toPoint: CGPointMake(300,400)) {
          print("moved to 300,400")
          self.testChainingAnimation()
        }
      }
    }
  }
  func testCustomPropertyAnimation(){
    self.v.m_animate("xy_rotation", toValues: [π/4,0]) {
      self.v.m_animate("xy_rotation", toValues: [0,π/4]) {
        self.testCustomPropertyAnimation()
      }
    }
  }
  func tap(gr:UITapGestureRecognizer){
    let p = gr.locationInView(view)
    v.m_animate("center", toPoint:p, stiffness:200, damping:10, onUpdate:updateRotationWithVelocity)
  }
  
  var startPoint:CGPoint!
  func pan(gr:UIPanGestureRecognizer){
    let trans = gr.translationInView(view)
    switch gr.state{
    case .Began:
      startPoint = v.center
    case .Changed, .Ended:
      let p = startPoint + trans
      v.m_animate("center", toPoint:p, stiffness:500, damping:20, onUpdate:updateRotationWithVelocity)
    default:
      break
    }
  }
  
  func updateRotationWithVelocity(velocity:CGPoint){
    let maxRotate = π/2
    self.v.m_animate("xy_rotation", toValues: [-(velocity.y/1000).clamp(-maxRotate,maxRotate),(velocity.x/1000).clamp(-maxRotate,maxRotate)], stiffness: 120, damping: 20, threshold: 0.001)
  }
}
