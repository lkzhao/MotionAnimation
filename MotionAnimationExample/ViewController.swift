//
//  ViewController.swift
//  MotionAnimation
//
//  Created by YiLun Zhao on 2016-02-07.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


// Manages page scroll. not related to MotionAnimation
// Please checkout the "Examples" folder
class ViewController: UIPageViewController {
  let vcs:[UIViewController] = [SquareViewController(), ListViewController()]

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = self;
    self.setViewControllers([vcs[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }
}

extension ViewController: UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
    return vcs[(vcs.index(of: viewController)! - 1 + vcs.count) % vcs.count];
  }
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
    return vcs[(vcs.index(of: viewController)! + 1) % vcs.count];
  }
}
