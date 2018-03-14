/*
Copyright (c) 2010 Trevor McCauley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
*/
package com.senocular.display.transform {
	
	import com.senocular.events.TransformEvent;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * Allows the user to move the target object by clicking and dragging on
	 * it. There are no graphics associated with ControlMove instances so no
	 * styling applies.  All interaction is handled through the target object
	 * of the TransformTool instance.
	 * @author Trevor McCauley
	 * @author modified by Shuang
	 */
	public class ControlMove extends ControlRestrictBounds {
		
		/**
		 *
		 */
		public function get keyEnabled():Boolean {
			return _keyEnabled;
		}
		public function set keyEnabled(value:Boolean):void {
			_keyEnabled = value;
		}
		protected var _keyEnabled:Boolean = false;
		
		/** 
		 * @private 
		 */
		protected var isDown:Boolean;
		
		/** 
		 * @private 
		 */
		protected var distanceX:Number;
		
		/** 
		 * @private 
		 */
		protected var distanceY:Number;
		
		/** 
		 * @private 
		 */
		protected var _mouseDownTrigger:Boolean = true;
		
		/**
		 * Whether is selected immediately after the item is clicked.
		 */
		public function set mouseDownTrigger(value:Boolean):void {
			_mouseDownTrigger = value;
		}
		public function get mouseDownTrigger():Boolean {
			return _mouseDownTrigger;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set tool(value:TransformTool):void {
			if (value == _tool) return;
			var items:Array;
			var i:int;
			if (_tool) {
				_tool.removeEventListener(TransformEvent.ADD_ITEM, initTargetEvents);
				_tool.removeEventListener(TransformEvent.REMOVE_ITEM, clearTargetEvents);
				items = tool.items;
				i = items.length;
				while (i--)
					clearTargetEvents((items[i] as TransformItem).target);
				
			}
			
			super.tool = value;
			if (_tool) {
				items = _tool.items;
				i = items.length;
				while (i--) {
					trace((items[i] as TransformItem).target, "target")
					initTargetEvents((items[i] as TransformItem).target);
				}
				tool.addEventListener(TransformEvent.ADD_ITEM, initTargetEvents, false, 0, true);
				tool.addEventListener(TransformEvent.REMOVE_ITEM, clearTargetEvents, false, 0, true);
			}
		}
		
		/**
		 * Constructor for creating new ControlMove instances.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance. For ControlMove instances, this cursor is
		 * displayed when interacting with the Transform Tool's target
		 * object.
		 */
		public function ControlMove(cursor:Cursor=null){
			super(cursor);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function selectionChanged(event:TransformEvent):void {
			var targetEvent:MouseEvent = tool.targetEvent as MouseEvent;
			if (targetEvent && tool.selectedItems.indexOf(tool.getItem(targetEvent.target as DisplayObject)) == -1) {
				super.selectionChanged(event);
				if (targetEvent.type == MouseEvent.MOUSE_DOWN)
					rollOverHandler(targetEvent);
				
			}
			
			if (activeMouseEvent)
				showOrHideGhostImage();
			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseMove(event:MouseEvent):void {
			super.activeMouseMove(event);
			
			// moves the transform using the current mouse position.
			recordKeyInformation();
			
			tool.move(endPoint.x - distanceX, endPoint.y - distanceY);
			tool.update(false);
			
			keepWithinBounds();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mouseDownHandler(event:MouseEvent):void {
			tool.select(event);
			super.mouseDownHandler(event);
			
			setKeyInformation();
			
			calculateDistance();
			
			showOrHideGhostImage();
			
			if (_mouseDownTrigger) { 
				tool.update(false);
				
				updateMousePositions(event);
				
				calculateDistance();
			}
		}
		
		/**
		 * @private
		 */
		protected function calculateDistance():void {
			distanceX = endPoint.x - tool.x;
			distanceY = endPoint.y - tool.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseUp(event:MouseEvent):void {
			super.activeMouseUp(event);
			showOrHideGhostImage(false);
		}
		
		/**
		 * @private
		 */
		protected function initTargetEvents(value:*):void {
			trace(((value is TransformEvent) ? value.item.target : value) as DisplayObject, "target1")
			initMouseEvents(((value is TransformEvent) ? value.item.target : value) as DisplayObject);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyEventHandler, false, 0, true);
		}
		
		/**
		 * @private
		 */
		protected function clearTargetEvents(value:*):void {
			clearMouseEvents(((value is TransformEvent) ? value.item.target : value) as DisplayObject);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyEventHandler);
		}
		
		/**
		 * @private
		 */
		protected function keyEventHandler(event:KeyboardEvent):void {
			if (!_keyEnabled) return;
			
			if (event.type == KeyboardEvent.KEY_DOWN) {
				if (!isDown) {
					updateTransform();
					isDown = true;
				}
				
				var keyCode:uint = event.keyCode;
				
				if (event.ctrlKey && keyCode == 65)
					tool.selectItems(tool.items);
				else if (tool.selectedItems.length > 0) {
					
					//move faster if the shift key is down.
					var amount:int = event.shiftKey ? 10 : 1;
					
					switch (keyCode) {
						case Keyboard.ESCAPE:
							tool.deselect();
							return;
						case Keyboard.UP:
							tool.y -= amount;
							break;
						case Keyboard.DOWN:
							tool.y += amount;
							break;
						case Keyboard.LEFT:
							tool.x -= amount;
							break;
						case Keyboard.RIGHT:
							tool.x += amount;
							break;
						default:
							return;
					}
					
					tool.update(false);
					keepWithinBounds();
					event.updateAfterEvent();
				}
				
			} else {
				updateTransform();
				isDown = false;
			}
		}
		
	}
}