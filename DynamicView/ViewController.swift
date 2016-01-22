////
////  ViewController.swift
////  DynamicView
////
////  Created by YiLun Zhao on 2016-01-16.
////  Copyright © 2016 lkzhao. All rights reserved.
////
//
//import UIKit
//
//
//class LKPageView:UIView {
//  var label:UILabel!
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    label = UILabel(frame: CGRectMake(0, 18, frame.width, 44))
//    label.text = "test"
//    label.textAlignment = .Center
//    label.textColor = UIColor.whiteColor()
//    self.addSubview(label)
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//  }
//
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    label.frame = CGRectMake(0, 18, frame.width, 44)
//  }
//}
//
//
//class ViewController: UIViewController {
//  var dynamicView:UIView!
//  var listViews:[UIView] = []
//  var currentListView:UIView{
//    return listViews[currentListViewIndex]
//  }
//  var currentListViewIndex:Int = 0
//  var contentView:UIView!
//  var contentViewCenter:CGPoint!
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    MotionAnimator.sharedInstance.debugEnabled = true
//    for i in 0...3{
//      let listView = LKPageView(frame: view.frame)
//      listView.layer.zPosition = CGFloat(i)
//      listView.layer.cornerRadius = 5
//      listView.backgroundColor = UIColor(red: 0, green: 190/255 - CGFloat(i)/10, blue: 1.0 - CGFloat(i)/5, alpha: 1)
//      let pan = UIPanGestureRecognizer(target: self, action: "pan:")
//      listView.addGestureRecognizer(pan)
//      let tap = UITapGestureRecognizer(target: self, action: "tap:")
//      listView.addGestureRecognizer(tap)
//      listView.m_defineCustomProperty("scale", initialValue: [1], valueUpdateCallback: { (scale) -> Void in
//        listView.layer.transform = CATransform3DMakeScale(scale[0], scale[0], 1)
//      })
////      listView.m_defineCustomProperty("zHeight", initialValue: 0, valueUpdateCallback: { (zHeight) -> Void in
////        listView.layer.shadowOpacity = 0.4
////        listView.layer.shadowColor = UIColor.blackColor().CGColor
////        listView.layer.shadowRadius = zHeight
////        listView.layer.shadowOffset = CGSize(width: 0, height: zHeight)
////      })
//      listViews.append(listView)
//      view.addSubview(listView)
//    }
//    currentListViewIndex = listViews.count - 1
//    
//    contentView = UIView(frame: CGRectMake(0,64,view.frame.width,view.frame.height-64))
//    contentView.backgroundColor = UIColor.whiteColor()
//    contentViewCenter = contentView.center
//    contentView.layer.zPosition = 20
//    view.addSubview(contentView)
//  }
//  
//  var startPoint:CGPoint = CGPointZero
//  
//  func destinationPointForIndex(index:Int, inListView:Bool) -> CGPoint{
//    if inListView{
//      return CGPointMake(view.center.x, CGFloat(index - listViews.count) * 80 + view.frame.height * 1.5 - 100)
//    }else{
//      if index > currentListViewIndex{
//        return CGPointMake(view.center.x, view.frame.height*2)
//      }else{
//        return view.center
//      }
//    }
//  }
//  func destinationPointForContentView(inListView:Bool) -> CGPoint{
//    if inListView{
//      return CGPointMake(view.center.x, view.frame.height*2)
//    }else{
//      return contentViewCenter
//    }
//  }
//  func destinationScaleForIndex(index:Int, inListView:Bool) -> CGFloat{
//    if inListView{
//      return 0.95 - CGFloat(listViews.count - index)*0.025
//    }else{
//      return 1
//    }
//  }
//  
//  var showListView = false{
//    didSet{
//      if showListView{
//        contentView.m_animate("center", toPoint: CGPointMake(view.center.x, view.frame.height*2))
//      }else{
//        contentView.m_animate("center", toPoint: contentViewCenter)
//      }
//      for (i, list) in listViews.enumerate(){
////        list.m_animate("zHeight", toValue: showListView ? 15 : 0)
//        list.m_animate("center", toPoint: destinationPointForIndex(i, inListView: showListView))
//        list.m_animate("scale", toValue: destinationScaleForIndex(i, inListView: showListView))
//        list.m_animate("layer.cornerRadius", toValue: showListView ? 20 : 5)
//      }
//    }
//  }
//  
//  func getProgress(currentY:CGFloat) -> CGFloat{
//    let initialPoint = destinationPointForIndex(currentListViewIndex, inListView: showListView)
//    let finalPoint = destinationPointForIndex(currentListViewIndex, inListView: !showListView)
//    
//    if initialPoint.y < finalPoint.y{
//      if currentY < initialPoint.y{
//        return 0
//      }else if currentY > finalPoint.y{
//        return 1
//      }else{
//        return (currentY - initialPoint.y) / initialPoint.distance(finalPoint)
//      }
//    }else{
//      if currentY > initialPoint.y{
//        return 0
//      }else if currentY < finalPoint.y{
//        return 1
//      }else{
//        return (initialPoint.y - currentY) / initialPoint.distance(finalPoint)
//      }
//    }
//  }
//  
//  func pan(gr:UIPanGestureRecognizer){
//    let trans = gr.translationInView(view)
//    switch gr.state{
//    case .Began:
//      print("pan")
//      currentListViewIndex = listViews.indexOf(gr.view!)!
//      startPoint = currentListView.center
//      for list in listViews{
//        list.m_animate("layer.cornerRadius", toValue: 20)
////        list.m_animate("zHeight", toValue: 15)
//      }
//    case .Changed, .Ended:
//      var targetY = startPoint.y + trans.y
//      let edgePoint:CGPoint
//      if showListView{
//        edgePoint = destinationPointForIndex(currentListViewIndex, inListView: showListView)
//      }else{
//        edgePoint = destinationPointForIndex(currentListViewIndex, inListView: !showListView)
//      }
//      if targetY > edgePoint.y{
//        targetY = edgePoint.y + (targetY - edgePoint.y)*0.3
//      }
//      let targetPoint = CGPointMake(view.center.x + trans.x * 0.2, targetY)
//
//      currentListView.m_animate("center", toPoint:targetPoint)
//      
//      let progress = getProgress(targetPoint.y)
//      let initialCPoint = destinationPointForContentView(showListView)
//      let finalCPoint = destinationPointForContentView(!showListView)
//      contentView.m_animate("center", toPoint: progress * (finalCPoint - initialCPoint) + initialCPoint)
//      
//      for (i, list) in listViews.enumerate(){
//        let initialPoint = destinationPointForIndex(i, inListView: showListView)
//        let finalPoint = destinationPointForIndex(i, inListView: !showListView)
//        let initialScale = destinationScaleForIndex(i, inListView: showListView)
//        let finalScale = destinationScaleForIndex(i, inListView: !showListView)
//        if i != currentListViewIndex{
//          var y = (progress * (finalPoint - initialPoint) + initialPoint).y
//          if i > currentListViewIndex{
//            y = max(y, CGFloat(i - currentListViewIndex) * 80 + targetPoint.y)
//          }
//          let x = view.center.x + (targetPoint.x - view.center.x) * max(0, (1 - CGFloat(abs(i - currentListViewIndex)) * 0.3))
//          list.m_animate("center", toPoint: CGPointMake(x, y))
//        }
//        list.m_animate("scale", toValue: progress * (finalScale - initialScale) + initialScale)
//      }
//      if gr.state == .Ended {
//        showListView = progress > 0.3 ? !showListView : showListView
//      }
//    default:
//      break
//    }
//  }
//  
//  func tap(tapGR:UITapGestureRecognizer){
//    print("tap")
//    currentListViewIndex = listViews.indexOf(tapGR.view!)!
//    showListView = !showListView
//  }
//
//  override func preferredStatusBarStyle() -> UIStatusBarStyle {
//    return .LightContent
//  }
//}
//
