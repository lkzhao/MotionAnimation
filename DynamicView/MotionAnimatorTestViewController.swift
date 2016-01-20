//
//  MotionAnimatorTestViewController.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class MotionAnimatorTestViewController: UIViewController {

  var useMotion = true
  var v:UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    v = UIView(frame: CGRectMake(100,200,50,50))
    v.backgroundColor = UIColor.redColor()
    view.addSubview(v)
    
    if useMotion{
      MotionAnimator.sharedInstance.debugEnabled = true
      v.m_animate("center", toPoint: view.center, stiffness: 200, damping: 10)
    }else{
      let anim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
      anim.toValue = NSValue(CGPoint:CGPointMake(125, 425))
      anim.springBounciness = 20
      v.layer.pop_addAnimation(anim, forKey: "posn")
    }
    
    let pan = UIPanGestureRecognizer(target: self, action: "pan:")
    v.addGestureRecognizer(pan)

    let tap = UITapGestureRecognizer(target: self, action: "tap:")
    view.addGestureRecognizer(tap)
    
//    NSTimer.schedule(repeatInterval: 0.5) { (_) -> Void in
//      self.testLoop()
//    }
    testChainingAnimation()
  }
  
  var usingPointA = false
  func testLoop(){
    let p = usingPointA ? CGPointMake(0,0):view.center
    if useMotion{
      v.m_animate("center", toPoint: p)
    }else{
      if let anim = v.layer.pop_animationForKey("posn") as? POPSpringAnimation {
        anim.toValue = NSValue(CGPoint:p)
      }else{
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        anim.toValue = NSValue(CGPoint:p)
        anim.springBounciness = 20
        v.layer.pop_addAnimation(anim, forKey: "posn")
      }
    }
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
  func tap(gr:UITapGestureRecognizer){
    let p = gr.locationInView(view)
    if useMotion{
      v.m_animate("center", toPoint: p)
    }else{
      if let anim = v.layer.pop_animationForKey("posn") as? POPSpringAnimation {
        anim.toValue = NSValue(CGPoint:p)
      }else{
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        anim.toValue = NSValue(CGPoint:p)
        anim.springBounciness = 20
        v.layer.pop_addAnimation(anim, forKey: "posn")
      }
    }
  }
  
  var startPoint:CGPoint!
  func pan(gr:UIPanGestureRecognizer){
    let trans = gr.translationInView(view)
    switch gr.state{
    case .Began:
      startPoint = v.center
    case .Changed, .Ended:
      let p = startPoint + trans
      if useMotion{
        v.m_animate("center", toPoint: p)
      }else{
        if let anim = v.layer.pop_animationForKey("posn") as? POPSpringAnimation {
          anim.toValue = NSValue(CGPoint:startPoint + trans)
        }else{
          let anim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
          anim.toValue = NSValue(CGPoint:startPoint + trans)
          anim.springBounciness = 20
          v.layer.pop_addAnimation(anim, forKey: "posn")
        }
      }
    default:
      break
    }
  }
}
