//
//  MainViewController.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-26.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  var rootNode:RootNode!
  override func viewDidLoad() {
    super.viewDidLoad()
    MotionAnimator.sharedInstance.debugEnabled = true
    rootNode = RootNode(rootViewController: self, rootViewNode: ListViewNode())
  }

}
