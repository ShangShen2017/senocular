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
	import flash.display.DisplayObjectContainer;
	import flash.events.EventPhase;
	import flash.events.IEventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Base class for interactive Transform Tool controls.  This class adds
	 * to the Control class including a framework for handling user 
	 * interaction through mouse events.
	 * updates.  For non-interactive controls, use Control, though it is
	 * not required for controls to extend the Control class to be used
	 * as a control of the Transform Tool.
	 * @author Trevor McCauley
	 * @author modified by Shuang
	 */
	public class ControlInteractive extends Control {
		
		/**
		 * @private
		 */
		protected static var withinBoundsMatrix:Matrix;
		
		/**
		 * @private
		 */
		protected static var prevX:Number;
		
		/**
		 * @private
		 */
		protected static var prevY:Number;
		
		/**
		 * @private
		 */
		protected static var prevBounds:Rectangle
		
		/**
		 * @private
		 * The object from which mouse events are consumed. This would normally
		 * be the stage instance, but root may be used if stage is not allowed.
		 */
		protected var activeTarget:IEventDispatcher;
		
		/**
		 * @private
		 * The most recent mouse event received by the activeTarget dispatcher 
		 * when consuming mouse events.
		 */
		protected var activeMouseEvent:MouseEvent;
		
		/**
		 * @private
		 * Mouse location within the Transform Tool coordinate space
		 * when the control is first clicked.
		 */
		protected var endPoint:Point;
		
		/**
		 * @private
		 */
		protected var mouseOffset:Point = new Point();
		
		/**
		 * @private
		 */
		protected var referencePoint:Point;
		
		/**
		 * @private
		 */
		protected var baseConstrainRotationAngle:Number;
		
		/**
		 * @private
		 * Indicates that a transform control has assumed control
		 * of the tool for interaction. Other controls would check
		 * this value to see if it is able to interact with the
		 * tool without interference from other controls.
		 */
		protected static var isActive:Boolean;
		
		/**
		 * The cursor to be used when interacting with this control.
		 */
		public function get cursor():Cursor {
			return _cursor;
		}
		public function set cursor(value:Cursor):void {
			if (value == _cursor)
				return;
			
			setupCursor();
			_cursor = value;
			cleanupCursor();
		}
		protected var _cursor:Cursor;
		
		/**
		 * @private
		 */
		protected function setupCursor():void {
			if (_cursor)
				_cursor.tool = tool;
			
		}
	
		/**
		 * @private
		 * Cleanup steps when defining a new cursor value. You may need to 
		 * override this method to control the order of operations when
		 * adding content to the set cursor setter.  This is called before
		 * a new cursor value is set.
		 */
		protected function cleanupCursor():void {
			if (_cursor)
				_cursor.tool = null;
			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function setupTool():void {
			// cursor needs to be set when tool
			// is defined but before setting
			// tool calls redraw (in setupTool)
			setupCursor();
			super.setupTool();
		}
		
		/**
		 * Constructor for creating new ControlInteractive instances.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance.
		 */
		public function ControlInteractive(cursor:Cursor=null) {
			super();
			this.cursor = cursor;
			
			// default style for interactive controls 
			fillColor = 0x000000;
			lineColor = 0xFFFFFF;
			lineThickness = 2;
		}
		
		/**
		 * 
		 */
		protected function initMouseEvents(target:DisplayObject):void {
			target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true); // interaction...
			target.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
		}
		
		/**
		 * 
		 */
		protected function clearMouseEvents(target:DisplayObject):void {
			target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			target.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			target.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function removedFromStage(event:Event):void {
			cleanupActiveMouse();
			super.removedFromStage(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function selectionChanged(event:TransformEvent):void {
			cleanupActiveMouse();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(event:*):void {
			if (_cursor != null)
				_cursor.redraw(event);
			
		}
		
		/**
		 * @private
		 * Handler for the MouseEvent.ROLL_OVER event for the control object.
		 * This is used to determine if the cursor needs to be changed.
		 */
		protected function rollOverHandler(event:MouseEvent):void {
			if (_cursor && tool && !isActive) 
				tool.setCursor(_cursor, event);
			
		}
		
		/**
		 * @private
		 * Handler for the MouseEvent.ROLL_OUT event for the control object.
		 * This is used to determine if the cursor needs to be changed.
		 */
		protected function rollOutHandler(event:MouseEvent):void {
			if (_cursor && tool && !isActive && !activeTarget)
				tool.setCursor(null);
			
		}
		
		/**
		 * @private
		 */
		protected function updateTransform():void {
			if (tool) {
				tool.updateTransform();
				tool.update();
			}
		}
		
		/**
		 * @private
		 * Handler for the MouseEvent.ROLL_OUT event for the control object.
		 * This is used to determine if the cursor needs to be changed.
		 */
		protected function mouseDownHandler(event:MouseEvent):void {
			if (tool && (tool.selectedItems.length > 0 || (this is ControlDragSelection && tool.items.length > 0))) {
				
				baseConstrainRotationAngle = tool.constrainRotationAngle;
				if (referencePoint) {
					// mouse offset to allow interaction from desired point
					var commonParent:DisplayObjectContainer = tool.commonParent;
					var mousePoint:Point = new Point(commonParent.mouseX, commonParent.mouseY);
					if (!tool.relative)
						mousePoint = commonParent.transform.concatenatedMatrix.transformPoint(mousePoint);
					
					mouseOffset.x = referencePoint.x - mousePoint.x;
					mouseOffset.y = referencePoint.y - mousePoint.y;
				}
				
				activeMouseEvent = event;
				updateBaseReferences();
				setupActiveMouse();
			}
			
		}
		
		/**
		 * @private
		 * Handler for the MouseEvent.MOUSE_MOVE event from the activeTarget
		 * object. This is used to update the active mouse positions.
		 */
		protected function activeMouseMove(event:MouseEvent):void {
			if (tool && (tool.selectedItems.length > 0 || (this is ControlDragSelection && tool.items.length > 0))) {
				activeMouseEvent = event;
				
				//updates active references for mouse positions. These references are
		        //used to represent the most up to date state of the mouse position
		        //as a control is being interacted with.
				updateMousePositions(activeMouseEvent);
			}
		}
		
		/**
		 * @private
		 * Handler for the MouseEvent.MOUSE_UP event (capture and no capture)
		 * from the activeTarget object.
		 * This is used to cleanup mouse handlers and commit the target object.
		 * This handler handles both capture and bubble/at-target phases but 
		 * does not perform its operations in phases other than capture and
		 * at-target.
		 */
		protected function activeMouseUp(event:MouseEvent):void {
			// only handle events down to and including the target
			if (event.eventPhase != EventPhase.BUBBLING_PHASE){
				
				activeMouseEvent = null;
				cleanupActiveMouse();
				tool.uniformScaleX = tool.uniformScaleY = NaN;
				tool.constrainRotationAngle = baseConstrainRotationAngle;
				// commit after cleaning up the active mouse variables
				// specifically.
				tool.update()
			}
		}
		
		/**
		 * @private
		 * Handler for the MouseEvent.MOUSE_UP event for the control object.
		 * This is used to set the cursor
		 */
		protected function mouseUpHandler(event:MouseEvent):void {
			if (tool != null)
				tool.setCursor(_cursor, event);
			
		}
		
		/**
		 * @private
		 * Intializes variables and listeners for tracking the mouse location.
		 */
		protected function setupActiveMouse():void {
			activeTarget = null;
			if (stage && loaderInfo && loaderInfo.parentAllowsChild) {
				// standard, expected target
				activeTarget = stage;
				
			} else if (root) {
				// since without the stage, we can't identify mouse-up-outside
				// events, we have to resort to using the rolling out of the
				// content we actually have access to getting events from 
				activeTarget = root;
				activeTarget.addEventListener(MouseEvent.ROLL_OUT, activeMouseUp, false, 0, true);
			}
			
			if (activeTarget) {
				isActive = true
				activeTarget.addEventListener(MouseEvent.MOUSE_MOVE, activeMouseMove, false, 0, true);
				// Capture phase used here in case the interaction
				// target, or some other object within its hierarchy
				// stops propagation of the event preventing the
				// tool from recognizing the completion of its use
				activeTarget.addEventListener(MouseEvent.MOUSE_UP, activeMouseUp, true, 0, false);
				activeTarget.addEventListener(MouseEvent.MOUSE_UP, activeMouseUp, false, 0, false);
			}
		}
		
		/**
		 * @private
		 * Clears variables and listeners for tracking the mouse location.
		 */
		protected function cleanupActiveMouse():void {
			var tool:TransformTool = this.tool;
			
			if (activeTarget) {
				activeTarget.removeEventListener(MouseEvent.ROLL_OUT, activeMouseUp);
				activeTarget.removeEventListener(MouseEvent.MOUSE_MOVE, activeMouseMove);
				activeTarget.removeEventListener(MouseEvent.MOUSE_UP, activeMouseUp, true);
				activeTarget.removeEventListener(MouseEvent.MOUSE_UP, activeMouseUp, false);
				activeTarget = null;
				isActive = false;
			}
			
			if (tool.cursor == _cursor)
				tool.setCursor(null);
			
		}
		
		/**
		 * @private
		 * Updates the values of the base references.
		 */
		protected function updateBaseReferences():void {
			var tool:TransformTool = this.tool;
			// make sure the base transform is at a minimum size for transformations, 
			// i.e. it is not 0-scaled preventing certain transformations to fail
			if (tool.normalizeBase())
				tool.update();
			
			updateMousePositions(activeMouseEvent);
		}
		
		/**
		 * @private
		 * Updates mouse position references from the provided mouse
		 * event.
		 * @param	event MouseEvent from which to obtain mouse positions.
		 */
		protected function updateMousePositions(event:MouseEvent=null):void {
			var commonParent:DisplayObjectContainer = tool.commonParent;
			if (commonParent) {
				
				endPoint = new Point(commonParent.mouseX, commonParent.mouseY);
				if (!tool.relative)
					endPoint = commonParent.transform.concatenatedMatrix.transformPoint(endPoint);
				
			} //else if (tool.target == stage) {
				
			//}
			
			endPoint = endPoint.add(mouseOffset);
		}
		
	}
}