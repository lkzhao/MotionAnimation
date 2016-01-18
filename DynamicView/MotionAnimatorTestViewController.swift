//
//  MotionAnimatorTestViewController.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class MotionAnimatorTestViewController: UIViewController {

  var springBehavior:SpringMultiValueAnimation!
  var useMotion = true
  var v:UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    v = UIView(frame: CGRectMake(100,200,50,50))
    v.backgroundColor = UIColor.redColor()
    view.addSubview(v)
    
    if useMotion{
      MotionAnimator.sharedInstance.debugEnabled = true
      springBehavior = SpringMultiValueAnimation(getter: { () -> [CGFloat] in
          return [self.v.center.x, self.v.center.y]
        }, setter: { (newCenter) -> Void in
          self.v.center = CGPointMake(newCenter[0], newCenter[1])
        }, target: [125, 225])
      springBehavior.k = 200
      springBehavior.b = 10
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
//      self.test()
//    }
  }
  
  var usingPointA = false
  func test(){
    let p = usingPointA ? CGPointMake(0,0):view.center
    if useMotion{
      springBehavior.target = [p.x, p.y]
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
  func tap(gr:UITapGestureRecognizer){
    let p = gr.locationInView(view)
    if useMotion{
      springBehavior.target = [p.x, p.y]
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
        springBehavior.target = [p.x, p.y]
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
