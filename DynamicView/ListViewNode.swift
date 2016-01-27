//
//  ListViewNode.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-26.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class RoundButtonNode: ViewNode {
  override func constructView() -> UIView {
    let v = UIView()
    v.addGestureRecognizer(LZPanGestureRecognizer(target: self, action: "pan:"))
    return v
  }
  
  func pan(gr:LZPanGestureRecognizer){
    self.state.onDrag?(gr:gr)
  }

  override func applyState(state: ViewNodeState?) {
    super.applyState(state)
    view?.backgroundColor = UIColor.blueColor()
    view?.layer.cornerRadius = 20
  }
}



class ListViewNode: ViewNode {
  class ListViewState:ViewNodeState {
    var buttonState = ViewNodeState(frame: CGRectMake(50, 100, 40, 40))
  }

  // no view yet
  override func constructView() -> UIView {
    let v = UIView()
    v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tap:"))
    return v
  }
  
  func tap(gr:UITapGestureRecognizer){
    if let state = self.state as? ListViewState{
      state.buttonState.frame?.origin = gr.locationInView(view) - CGPointMake(20, 20)
      self.state = state
    }
  }
  func pan(gr:LZPanGestureRecognizer){
    if let state = self.state as? ListViewState{
      state.buttonState.center = gr.translatedViewCenterPoint
      self.state = state
    }
  }

  // no view yet
  override func setup() {
    super.setup()
    addSubnode("Button", node: RoundButtonNode())
  }
  
  override func getDefaultState() -> ViewNodeState {
    return ListViewState()
  }

  // view ready
  override func applyState(state: ViewNodeState?) {
    if let state = state as? ListViewState{
      super.applyState(state)
      view?.backgroundColor = UIColor.lightGrayColor()
      state.buttonState.onDrag = pan
      self["Button"]?.state = state.buttonState
    }
  }
}
