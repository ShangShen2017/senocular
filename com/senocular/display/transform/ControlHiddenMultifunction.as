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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	/**
	 * Combines moving, scaling, rotating and moving the registration point
	 * into a single, invisible control.  Each operation, except for moving,
	 * relies on a keyboard shortcuts to enable.
	 * @author Trevor McCauley
	 * @author modified by Shuang 2016
	 */
	public class ControlHiddenMultifunction extends ControlRestrictBounds {
		
		/**
		 * @private
		 */
		protected var baseScaleX:Number;
		
		/**
		 * @private
		 */
		protected var baseScaleY:Number;
		
		/** 
		 * @private 
		 */
		protected var baseAngle:Number;
		
		/** 
		 * @private 
		 */
		protected var basePoint:Point;
		
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
		protected var startMouseMove:Boolean;
		
		/**
		 * @inheritDoc
		 */
		override public function set tool(value:TransformTool):void {
			super.tool = value;
			
		 	// target display object to be transformed by the TransformTool.
		 	// control points may use the target to add listeners to, for example
		 	// to move the target by dragging it.  This value is automatically
		 	// updated through the TransformTool.TARGET_CHANGED event.
			var items:Array = _tool.items;
			var i:int = items.length;
			if (_tool) {
				while (i--)
					initMouseEvents((items[i] as TransformItem).target);
				
			} else {
				while (i--)
					clearMouseEvents((items[i] as TransformItem).target);
				
			}
		}
		
		/*
		 * Constructor for creating new ControlHiddenMultifunction instances.
		 */
		public function ControlHiddenMultifunction(cursor:Cursor = null){
			super(cursor);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function selectionChanged(event:TransformEvent):void {
			super.selectionChanged(event);
			
			if (activeMouseEvent)
				showOrHideGhostImage();
			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mouseDownHandler(event:MouseEvent):void {
			updateTransform();
			
			super.mouseDownHandler(event);
			
			recordKeyInformation();
			
			baseScaleX = tool.scaleX;
			baseScaleY = tool.scaleY;
			
			baseAngle = MatrixTool.getRotation(tool.calculatedMatrix, true);
			basePoint = endPoint.clone();
			
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
		 * @inheritDoc
		 */
		override protected function activeMouseMove(event:MouseEvent):void {
			super.activeMouseMove(event);
			
			// for rotation operations negative
			// scaling cannot be allowed
			// since it rotation will be misinterprettd
			// as scaling and restrictions will be 
			// applied when they should not
			var allowNegative:Boolean = true;
			
			if (event.shiftKey && event.ctrlKey) {
				scale();
				rotate();
			} else if (event.shiftKey) 
				scale();
				
			  else if (event.ctrlKey) {
				if (!startMouseMove) showOrHideGhostImage(true);
				rotate();
			  
			} else if (event.altKey) {
				
				// moves the registration point using the current mouse position
				tool.registration = endPoint.clone();
				// no need to calculate a transform
				// when only changing the registration point
				tool.update(false);
				
				setKeyInformation();
				
			} else if (!_tool.getControlByName("ControlMove")) {
				if (!startMouseMove) showOrHideGhostImage(true);
				
				// moves the transform using the current mouse position.
				recordKeyInformation();
				
				tool.move(endPoint.x - distanceX, endPoint.y - distanceY);
				tool.update(false);
				
				keepWithinBounds();
			}
			
			startMouseMove = true;
		}
		
		/** 
		 * @private 
		 */
		protected function scale():void {
			recordKeyInformation();
				
			tool.uniformScaleX = baseScaleX;
			tool.uniformScaleY = baseScaleY;
			tool.transformByPoint(referencePoint, endPoint, TransformMode.BOTH_SCALE);
			
			_tool.update(false);
			
			keepWithinBounds();
		}
		
		/** 
		 * @private 
		 */
		protected function rotate():void {
			var registration:Point = tool.registration;
				
			recordKeyInformation();
			
			// rotates a transform using the current mouse position.
			var m:Matrix = tool.calculatedMatrix;
			MatrixTool.setRotation(m, baseAngle + (Math.atan2(endPoint.y - registration.y, endPoint.x - registration.x) - Math.atan2(basePoint.y - registration.y, basePoint.x - registration.x)), true);
			
			tool.calculatedMatrix = m;
			tool.update(false);
			
			keepWithinBounds();
		}
	}
}