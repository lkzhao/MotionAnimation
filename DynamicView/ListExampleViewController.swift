//
//  ListExampleViewController.swift
//  DynamicView
//
//  Created by Luke on 1/21/16.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class ListExampleViewController: UIViewController {
  
  var listItems:[UIView] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1.0, alpha: 1)
    
    var lastView:UIView!
    MotionAnimator.sharedInstance.debugEnabled = true
    for i in 0...7{
      let v = UIView(frame: CGRectMake(75 - view.frame.width,75+CGFloat(i)*60,view.frame.width-150,50))
      v.layer.cornerRadius = 5
      v.backgroundColor = UIColor.whiteColor()
      view.addSubview(v)
      listItems.append(v)
      
      if lastView != nil{
        lastView.m_addValueUpdateCallback("center", valueUpdateCallback: .CGPointObserver({ point in
          v.m_animate("center", to: CGPointMake(point.x, v.center.y), stiffness: 200, damping:15)
        }))
      }
      lastView = v
      
      let gr = LZPanGestureRecognizer(target: self, action: "pan:")
      gr.xRange = 100...view.frame.width-100
      gr.yRange = v.center.y...v.center.y
      gr.yOverflowScale = 0
      v.addGestureRecognizer(gr)
    }
    
    listItems.first?.m_animate("center", to: CGPointMake(view.center.x, 100), stiffness: 200, damping:15, threshold:1)
//    testLoop()
    
  }
  
  func pan(gr:LZPanGestureRecognizer){
    guard let grView = gr.view else {return}
    switch gr.state{
    case .Began, .Changed:
      let p = gr.translatedViewCenterPoint
      grView.m_animate("center", to: p, stiffness: 500, damping:25)
    default:
      grView.m_animate("center", to: CGPointMake(view.center.x, grView.center.y), stiffness: 200, damping:15)
    }
  }
  
  func testLoop(){
    listItems.first?.m_animate("center", to: CGPointMake(view.center.x, 100), threshold:1) {
      self.listItems.first?.m_animate("center", to: CGPointMake(-100, 100), threshold:1) {
        self.testLoop()
      }
    }
  }
  
}
