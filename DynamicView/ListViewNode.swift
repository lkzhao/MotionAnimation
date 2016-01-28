//
//  ListViewNode.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-26.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class RoundButtonNode: ViewNode {

  override func didTransferedToView(){
    view!.addGestureRecognizer(LZPanGestureRecognizer(target: self, action: "pan:"))
    view!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tap:"))
  }

  func tap(gr:UITapGestureRecognizer){
    self.state.onTap?(node:self, gr:gr)
  }

  func pan(gr:LZPanGestureRecognizer){
    self.state.onDrag?(node:self, gr:gr)
  }

  override func applyState(state: ViewNodeState?) {
    super.applyState(state)
    view?.backgroundColor = UIColor.blueColor()
    view?.layer.cornerRadius = 20
  }
}



class ListViewNode: ViewNode {
  class ListViewState:ViewNodeState {
    var listItemStates:[String] = []
  }
  
  func tap(node:ViewNode, gr:UITapGestureRecognizer){
    let newNode = PanViewNode(listNode: self, key: node.key!)
    swapWithNode(newNode)
  }

  // no view yet
  override func setup() {
    super.setup()
  }
  
  override func getDefaultState() -> ViewNodeState {
    let state = ListViewState()
    state.listItemStates = ["Test", "Test2"]
    return state
  }

  var listItems:[RoundButtonNode] = []
  // view ready
  override func applyState(state: ViewNodeState?) {
    if let state = state as? ListViewState{
      super.applyState(state)
      while state.listItemStates.count > listItems.count{
        let n = RoundButtonNode()
        addSubnode("Item \(listItems.count)", node: n)
        listItems.append(n)
      }

      weak var v = view
      v?.m_defineCustomProperty("backgroundColor", initialValues: [1,1,1,1], valueUpdateCallback: { (values) -> Void in
        v?.backgroundColor = UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
      })
      v?.m_animate("backgroundColor", to: [1,1,1,1])

      for (i, item) in listItems.enumerate(){
        item.state = ViewNodeState(frame: CGRectMake(50, 50+CGFloat(i)*50, view!.frame.width - 100, 40), onTap: tap)
      }
    }
  }
}
