//
//  ListExampleViewController.swift
//  DynamicView
//
//  Created by Luke on 1/21/16.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class ListViewController: ExampleBaseViewController {
  
  var listItems:[UIView] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    
    var lastListItem:UIView!
    for i in 0...7{
      // configure each item
      let size = CGSizeMake(view.frame.width-150,50)
      let v = UIView(frame: CGRect(origin: CGPointZero, size: size))
      v.center = CGPointMake(view.center.x, 150 + CGFloat(i)*60)
      v.layer.cornerRadius = 5
      v.backgroundColor = UIColor.whiteColor()
      view.addSubview(v)
      listItems.append(v)
      
      // setup gesture recognizer on this item
      let gr = LZPanGestureRecognizer(target: self, action: "pan:")
      gr.xRange = 100...view.frame.width-100
      gr.yRange = v.center.y...v.center.y
      gr.yOverflowScale = 0
      v.addGestureRecognizer(gr)
      
      // link this item's center point to the previous item's center point
      if lastListItem != nil{
        lastListItem.m_addValueUpdateCallback("center", valueUpdateCallback: .CGPointObserver({ point in
          v.m_animate("center", to: CGPointMake(point.x, v.center.y), stiffness: 200, damping:15)
        }))
      }
      lastListItem = v
    }
    
    // animate our first item in to the view
    // since the rest of the items are linked, they will follow as well
    listItems.first?.m_animate("center", to: CGPointMake(view.center.x, 150), stiffness: 200, damping:15, threshold:1)
  }
  
  func pan(gr:LZPanGestureRecognizer){
    switch gr.state{
    case .Began, .Changed:
      // move the item under touch
      gr.view!.m_animate("center", to: gr.translatedViewCenterPoint, stiffness: 500, damping:25)
    default:
      // reset the item to the center
      gr.view!.m_animate("center", to: CGPointMake(view.center.x, gr.view!.center.y), stiffness: 200, damping:15)
    }
  }
}
