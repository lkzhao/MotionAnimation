//
//  AppDelegate.swift
//  MotionAnimation
//
//  Created by YiLun Zhao on 2016-02-07.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window!.rootViewController = ViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
//    window!.rootViewController = SquareViewController()
    window!.makeKeyAndVisible()
    return true
  }


}

