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
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import com.senocular.events.TransformEvent;
	
	/**
	 * Allows the user to rotate the target object.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao
	 */
	public class ControlRotate extends ControlInternal {
		
		/** 
		 * @private 
		 */
		protected var baseAngle:Number;
		
		/** 
		 * @private 
		 */
		protected var basePoint:Point;
		
		/**
		 * The replacement of the skin.
		 */
		public function set skin(skin:DisplayObject):void {
			skinOfCenterPosition(skin);
		}
		public function get skin():DisplayObject {
			return _skin;
		}
		
		/**
		 * Constructor for creating new ControlRotate instances.
		 * @param	
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance. 
		 */
		public function ControlRotate(positionType:String, cursor:Cursor = null){
			super(positionType, cursor);
			initMouseEvents(this);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			graphics.clear();
			
			// don't draw anything if something
			// has been added as a child to
			// this display object as a "skin"
			if (_skin) return;
			with (graphics){
				beginFill(this.fillColor, this.fillAlpha);
				lineStyle(this.lineThickness, this.lineColor, this.lineAlpha);
				drawCircle(0, 0, 4);
			}
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
			
			baseAngle = MatrixTool.getRotation(tool.calculatedMatrix, true);
			basePoint = endPoint.clone();
			
			showOrHideGhostImage();
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
			var registration:Point = tool.registration;
			
			recordKeyInformation();
			
			// rotates a transform using the current mouse position.
			var m:Matrix = tool.calculatedMatrix;
			
			MatrixTool.setRotation(m, baseAngle + (Math.atan2(endPoint.y - registration.y, endPoint.x - registration.x) - Math.atan2(basePoint.y - registration.y, basePoint.x - registration.x)), true);
			
			// snap to 45 degree angles.
			tool.constrainRotationAngle = event.shiftKey ? (Math.PI / 4) : baseConstrainRotationAngle;
			
			tool.calculatedMatrix = m;
			
			tool.update(false);
			
			keepWithinBounds();
		}
		
	}
}