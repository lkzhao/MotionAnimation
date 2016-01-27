//
//  MainViewController.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-26.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  let rootNode = ListViewNode()
  override func viewDidLoad() {
    super.viewDidLoad()
    rootNode.setup()
    rootNode.initializeView()
    view.addSubview(rootNode.view!)
    let state = rootNode.getDefaultState()
    state.animate = false
    state.frame = view.bounds
    rootNode.state = state
    state.animate = true
    rootNode.state = state
  }

}
