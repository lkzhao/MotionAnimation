//
//  MotionAnimatorTestViewController.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

let π = CGFloat(M_PI)

class SquareViewController: ExampleBaseViewController {

  var square:UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // configure our white square
    square = UIView(frame: CGRectMake(-150,view.center.y-75,150,150))
    square.layer.cornerRadius = 10
    square.backgroundColor = UIColor.whiteColor()
    view.addSubview(square)

    // setup gesture recognizers
    square.addGestureRecognizer(LZPanGestureRecognizer(target: self, action: #selector(SquareViewController.pan(_:))))
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SquareViewController.tap(_:))))

    // define a custom animation property
    square.m_defineCustomProperty("xy_rotation", initialValues: CGPointZero){ newValues in
      let pointValue = CGPoint.fromCGFloatValues(newValues)
      var t = CATransform3DIdentity
      t.m34 = 1.0 / -500;
      t = CATransform3DRotate(t, pointValue.x, 1.0, 0, 0)
      t = CATransform3DRotate(t, pointValue.y, 0, 1.0, 0)
      self.square.layer.transform = t
      let k = Float((abs(newValues[0]) + abs(pointValue.y)) / π / 1.5)
      self.square.layer.opacity = 1 - k
    }
    
    // when our center point changes, update our x, y rotation property
    square.m_addVelocityUpdateCallback("center", velocityUpdateCallback: CGPointObserver({ velocity in
      let maxRotate = π/2
      let rotateX = -(velocity.y/1000).clamp(-maxRotate,maxRotate)
      let rotateY = (velocity.x/1000).clamp(-maxRotate,maxRotate)
      self.square.m_animate("xy_rotation", to:CGPointMake(rotateX, rotateY), stiffness: 120, damping: 20, threshold: 0.001)
    }))

    // animate our view from offscreen to center of the screen
    square.m_animate("center", to: view.center, threshold: 1)
  }

  func tap(gr:UITapGestureRecognizer){
    square.m_animate("center", to: gr.locationInView(view), stiffness:200, damping:10)
  }

  func pan(gr:LZPanGestureRecognizer){
    // high stiffness -> high acceleration (will help it stay under touch)
    square.m_animate("center", to: gr.translatedViewCenterPoint, stiffness:500, damping:25)
  }
}