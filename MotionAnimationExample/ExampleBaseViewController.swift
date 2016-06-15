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
    
    let label = UILabel(frame: CGRect.zero)
    label.text = "\(self.dynamicType)"
    label.sizeToFit()
    label.textColor = UIColor.white()
    view.addSubview(label)
    label.center = CGPoint(x: view.center.x, y: 40)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }
}
