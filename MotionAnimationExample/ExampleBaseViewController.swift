//
//  ExampleBaseViewController.swift
//  MotionAnimation
//
//  Created by YiLun Zhao on 2016-02-07.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class ExampleBaseViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1.0, alpha: 1)
    
    let label = UILabel(frame: CGRectZero)
    label.text = "\(self.dynamicType)"
    label.sizeToFit()
    label.textColor = UIColor.whiteColor()
    view.addSubview(label)
    label.center = CGPointMake(view.center.x, 40)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}
