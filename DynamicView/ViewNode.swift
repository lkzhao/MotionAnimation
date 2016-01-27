//
//  ViewNode.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-26.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class ViewNodeState {
  var animate:Bool = true
  var frame:CGRect?
  var onDrag:((gr:LZPanGestureRecognizer) -> Void)?
  var center:CGPoint?{
    get{
      if let frame = frame{
        return CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2)
      }
      return nil
    }
    set{
      if let newCenter = newValue{
        let size = frame?.size ?? CGSizeZero
        frame = CGRectMake(newCenter.x - size.width/2, newCenter.y - size.height/2, size.width, size.height)
      }
    }
  }
  convenience init(frame:CGRect){
    self.init()
    self.frame = frame
  }
  init(){
    
  }
}

class ViewNode: NSObject {
  var view:UIView?
  weak var supernode:ViewNode?
  
  var subnodes:[String:ViewNode] = [:]
  
  func getDefaultState() -> ViewNodeState{
    return ViewNodeState()
  }
  
  func applyState(state:ViewNodeState?){
    if let state = state, frame = state.frame{
      if state.animate{
        view!.m_animate("frame", to: frame)
      }else{
        view!.frame = frame
      }
    }
  }
  
  private var initialized:Bool{
    return view != nil
  }
  
  func constructView() -> UIView{
    return UIView(frame: CGRectMake(0,0,50,50))
  }
  
  func setup(){
    
  }
  
  var _state:ViewNodeState!
  var state:ViewNodeState{
    get{
      if _state == nil{
        _state = getDefaultState()
      }
      return _state
    }
    set{
      _state = newValue
      applyState(_state)
    }
  }
  
  func initializeView(){
    if initialized{
      return
    }
    view = constructView()
    for (_, subnode) in subnodes{
      subnode.initializeView()
      view!.addSubview(subnode.view!)
    }
  }

  func addSubnode(key:String, node:ViewNode){
    if subnodes[key] == nil{
      subnodes[key] = node
      node.supernode = self
      node.setup()
      if initialized{
        node.initializeView()
        view!.addSubview(node.view!)
      }
    }
  }

  func removeSubnode(key:String){
    if let node = subnodes.removeValueForKey(key){
      // TODO
      if initialized{
        node.view?.removeFromSuperview()
      }
      node.supernode = nil
    }
  }

  subscript(subnodeKey: String) -> ViewNode? {
    get {
      return subnodes[subnodeKey]
    }
    set {
      if let node = newValue{
        addSubnode(subnodeKey, node: node)
      }
    }
  }
  
  func transferViews(fromNode:ViewNode){
    for (k, otherSubnode) in fromNode.subnodes{
      if let ourSubnode = subnodes[k]{
        ourSubnode.view = otherSubnode.view
      }
    }
  }
}
