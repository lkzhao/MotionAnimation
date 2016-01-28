//
//  ViewNode.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-26.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

typealias TapHandler = ((node:ViewNode, gr:UITapGestureRecognizer) -> Void)
typealias DragHandler = ((node:ViewNode, gr:LZPanGestureRecognizer) -> Void)

class ViewNodeState:NSObject {
  var animate:Bool = true
    var frame:CGRect?
    var onTap:TapHandler?
  var onDrag:DragHandler?
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
  convenience init(frame:CGRect, onTap:TapHandler? = nil, onDrag:DragHandler? = nil){
    self.init()
    self.frame = frame
    self.onTap = onTap
    self.onDrag = onDrag
  }
  override init(){
    
  }
}

class NodeLike:NSObject{
  func swapSubnode(node:ViewNode, toNode:ViewNode){}
}

class RootNode:NodeLike{
  var rootViewNode:ViewNode
  var rootViewController:UIViewController
  init(rootViewController:UIViewController, rootViewNode:ViewNode){
    self.rootViewController = rootViewController
    self.rootViewNode = rootViewNode
    super.init()

    rootViewNode.setup()
    rootViewNode.initializeView()

    rootViewController.view.addSubview(rootViewNode.view!)
    rootViewNode.supernode = self

    let state = rootViewNode.getDefaultState()
    state.animate = false
    state.frame = rootViewController.view.bounds
    rootViewNode.state = state
    state.animate = true
    rootViewNode.state = state
  }
  override func swapSubnode(node:ViewNode, toNode:ViewNode){
    if node === rootViewNode{
      rootViewNode = toNode
    }
  }
}

class ViewNode:NodeLike {
  var view:UIView?
  var key:String?
  weak var supernode:NodeLike?
  
  var subnodes:[String:ViewNode] = [:]
  
  dynamic func getDefaultState() -> ViewNodeState{
    return ViewNodeState()
  }
  
  func applyState(state:ViewNodeState?){
    if let state = state, frame = state.frame{
      if state.animate{
        view!.m_animate("frame", to: frame, stiffness: 200, damping: 25)
        view!.m_animate("alpha", to: 1, stiffness: 150, damping: 15)
      }else{
        view!.frame = frame
      }
    }
  }
  
  private var initialized:Bool{
    return view != nil
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
    if !initialized{
      view = UIView()
    }
    for (_, subnode) in subnodes{
      subnode.initializeView()
      view!.addSubview(subnode.view!)
    }
    didTransferedToView()
  }

  func didTransferedToView(){

  }

  func willTransferFromView(){
    if let grs = view?.gestureRecognizers{
      for gr in grs{
        view!.removeGestureRecognizer(gr)
      }
    }
  }

  func addSubnode(key:String, node:ViewNode){
    if subnodes[key] == nil{
      subnodes[key] = node
      node.supernode = self
      node.key = key
      node.setup()
      if initialized{
        node.initializeView()
        view!.addSubview(node.view!)
      }
    }
  }

  func removeSubnode(node:ViewNode){
    if let key = node.key{
      subnodes.removeValueForKey(key)
      if initialized{
        node.view?.removeFromSuperview()
      }
      node.supernode = nil
      node.key = nil
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

  func swapWithNode(node:ViewNode){
    node.setup()
    let notTransfered = node.transferFrom(self)
    for n in notTransfered{
      if let v = n.view{
        v.m_animate("alpha", to: 0, stiffness: 150, damping: 15) {
          v.removeFromSuperview()
        }
        // we dont dislink the view from the not transferred node since it might be transfered back
      }
    }
    supernode?.swapSubnode(self, toNode: node)
    node.initializeView()
    node.applyState(node.getDefaultState())
  }

  override func swapSubnode(node:ViewNode, toNode:ViewNode){
    if let key = node.key{
      subnodes.removeValueForKey(key)
      subnodes[key] = toNode
    }
  }
  
  func transferFrom(node:ViewNode) -> [ViewNode]{
    node.willTransferFromView()
    view = node.view
    var notTransferedNodes:[ViewNode] = []
    for (k, otherSubnode) in node.subnodes{
      if let ourSubnode = subnodes[k]{
        ourSubnode.transferFrom(otherSubnode)
        print("transferred \(k)")
      }else{
        notTransferedNodes.append(otherSubnode)
      }
    }
    node.view = nil
    initializeView()
    return notTransferedNodes
  }
}
