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

    let pan = UIPanGestureRecognizer(target: self, action: "pan:")
    v.addGestureRecognizer(pan)
    let tap = UITapGestureRecognizer(target: self, action: "tap:")
    view.addGestureRecognizer(tap)

    v.m_defineCustomProperty("xy_rotation", initialValues: [0, 0]) {(newValues) -> Void in
      var t = CATransform3DIdentity
      t.m34 = 1.0 / -500;
      t = CATransform3DRotate(t, newValues[0], 1.0, 0, 0)
      t = CATransform3DRotate(t, newValues[1], 0, 1.0, 0)
      self.v.layer.transform = t
      let k = Float((abs(newValues[0]) + abs(newValues[1])) / π / 1.5)
      self.v.layer.opacity = 1 - k
    }
    v.m_addVelocityUpdateCallback("center", velocityUpdateCallback: .CGPointObserver(updateRotationWithVelocity))

    v.m_animate("center", to: view.center, threshold: 1)
  }

  func tap(gr:UITapGestureRecognizer){
    let p = gr.locationInView(view)
    v.m_animate("center", to: p, stiffness:200, damping:10)
  }
  
  var startPoint:CGPoint!
  func pan(gr:UIPanGestureRecognizer){
    switch gr.state{
    case .Began:
      startPoint = v.center
    case .Changed, .Ended:
      let p = startPoint + gr.translationInView(view)
      // high stiffness means high acceleration (will help it stay under touch)
      v.m_animate("center", to: p, stiffness:500, damping:25)
    default:
      break
    }
  }

  func updateRotationWithVelocity(velocity:CGPoint){
    let maxRotate = π/2
    self.v.m_animate("xy_rotation", to:[-(velocity.y/1000).clamp(-maxRotate,maxRotate),(velocity.x/1000).clamp(-maxRotate,maxRotate)], stiffness: 120, damping: 20, threshold: 0.001)
  }
}

extension MotionAnimatorTestViewController{
    func testChainingAnimation(){
      self.v.m_animate("center", to: CGPointMake(255,255)) {
        self.v.m_animate("center", to: CGPointMake(100,100)) {
          self.v.m_animate("center", to: CGPointMake(300,400)) {
            self.testChainingAnimation()
          }
        }
      }
    }
    func testCustomPropertyAnimation(){
      self.v.m_animate("xy_rotation", to: [π/4,0]) {
        self.v.m_animate("xy_rotation", to: [0,π/4]) {
          self.testCustomPropertyAnimation()
        }
      }
    }
}
