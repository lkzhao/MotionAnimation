//
//  LZPanGestureRecognizer.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-25.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass


public class LZPanGestureRecognizer: UIPanGestureRecognizer {
  
  public var startViewCenterPoint:CGPoint?
  
  public var translatedViewCenterPoint:CGPoint{
    if let startViewCenterPoint = startViewCenterPoint{
      var p = startViewCenterPoint + translation(in: self.view!.superview!)
      p.x = clamp(p.x, range:xRange, overflowScale:xOverflowScale)
      p.y = clamp(p.y, range:yRange, overflowScale:yOverflowScale)
      return p
    }else{
      return self.view?.center ?? CGPoint.zero
    }
  }

  public func clamp(_ element: CGFloat, range:ClosedRange<CGFloat>, overflowScale:CGFloat = 0) -> CGFloat {
    if element < range.lowerBound{
      return range.lowerBound - (range.lowerBound - element)*overflowScale
    } else if element > range.upperBound{
      return range.upperBound + (element - range.upperBound)*overflowScale
    }
    return element
  }

  public var xOverflowScale:CGFloat = 0.3
  public var yOverflowScale:CGFloat = 0.3
  public var xRange:ClosedRange<CGFloat> = CGFloat.leastNormalMagnitude...CGFloat.greatestFiniteMagnitude
  public var yRange:ClosedRange<CGFloat> = CGFloat.leastNormalMagnitude...CGFloat.greatestFiniteMagnitude
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    
    if state == .failed{
      return
    }

    startViewCenterPoint = self.view?.center
  }
  
}
