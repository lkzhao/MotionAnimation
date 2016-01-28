//
//  PanViewNode.swift
//  DynamicView
//
//  Created by Luke on 1/27/16.
//  Copyright © 2016 lkzhao. All rights reserved.
//


class PanViewNode: ViewNode {
    class PanViewState:ViewNodeState {
        var buttonState = ViewNodeState(frame: CGRectMake(100, 100, 40, 40))
    }

  var listNode:ListViewNode
  var fromKey:String
  init(listNode:ListViewNode, key:String){
    self.listNode = listNode
    self.fromKey = key
  }

    func pan(node:ViewNode, gr:LZPanGestureRecognizer){
        if let state = self.state as? PanViewState{
            state.buttonState.center = gr.translatedViewCenterPoint
            self.state = state
        }
    }

  func tap(node:ViewNode, gr:UITapGestureRecognizer){
      swapWithNode(listNode)
    }

  var buttonNode = RoundButtonNode()
    override func setup() {
        super.setup()
        addSubnode(fromKey, node: buttonNode)
    }

    override func getDefaultState() -> ViewNodeState {
        return PanViewState()
    }

    // view ready
    override func applyState(state: ViewNodeState?) {
        if let state = state as? PanViewState{
            super.applyState(state)
          view?.m_animate("backgroundColor", to: UIColor.lightGrayColor())
          state.buttonState.onDrag = pan
          state.buttonState.onTap = tap
            buttonNode.state = state.buttonState
        }
    }
}
