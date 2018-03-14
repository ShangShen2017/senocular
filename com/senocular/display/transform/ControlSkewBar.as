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
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	/**
	 * Allows the user to skew the target object.  Unlike other controls, a
	 * ControlSkewBar instance is hidden by default. Unlike other ControlUV
	 * instances, ControlSkewBar uses two UV coordinates for positioning, 
	 * drawing a "line" from each to represent the active area of the control.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao 2012
	 */
	public class ControlSkewBar extends ControlInternal {
		
		/**
		 * Skew mode for skewing on the x axis.
		 */
		public static const X_AXIS:String = "xAxis";
		
		/**
		 * Skew mode for skewing on the y axis.
		 */
		public static const Y_AXIS:String = "yAxis";
		
		/**
		 * Skew mode for skewing. This can be* either X_AXIS, or Y_AXIS.
		 */
		public function get mode():String {
			return _mode;
		}
		public function set mode(value:String):void {
			_mode = value;
		}
		private var _mode:String;
		
		/**
		 * The size of the control, or the thickness of the "line" drawn 
		 * between (u,v) and (u2,v2) that represents the active area of
		 * the control.
		 */
		public function get thickness():Number {
			return _thickness;
		}
		public function set thickness(value:Number):void {
			_thickness = value;
		}
		private var _thickness:Number = 4;
		
		/** 
		 * @private 
		 */
		protected var baseMouse:Point;
		
		/** 
		 * @private 
		 */
		protected var baseMatrix:Matrix;
		
		/**
		 * Constructor for creating new ControlRotate instances.
		 * @param	
		 * @param	mode The transform mode to use for skewing. This can be
		 * either X_AXIS, or Y_AXIS.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance. 
		 */
		public function ControlSkewBar(positionType:String, mode:String = X_AXIS, cursor:Cursor = null) {
			super(positionType, cursor);
			initMouseEvents(this);
			this.mode = mode;
			fillAlpha = 0; // invisible
			lineThickness = NaN;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			redraw(null);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(event:*):void {
			//super.redraw(event);
			if (_cursor != null)
				_cursor.redraw(event);
			
			setPosition();
			
			graphics.clear();
			
			// do not draw if no tool or no thickness
			if (tool == null || !tool.commonParent || isNaN(_thickness))
				return;
			
			
			var type1:String, type2:String;
			switch (this.positionType) {
				case PositionMode.TOP_AXIS:
					type1 = PositionMode.TOP_LEFT;
					type2 = PositionMode.TOP_RIGHT;
					break;
				case PositionMode.BOTTOM_AXIS:
					type1 = PositionMode.BOTTOM_LEFT;
					type2 = PositionMode.BOTTOM_RIGHT;
					break;
				case PositionMode.LEFT_AXIS:
					type1 = PositionMode.TOP_LEFT;
					type2 = PositionMode.BOTTOM_LEFT;
					break;
				case PositionMode.RIGHT_AXIS:
					type1 = PositionMode.TOP_RIGHT;
					type2 = PositionMode.BOTTOM_RIGHT;
					break;
			}
			
			referencePoint = tool[type2];
			
			var start:Point = getPosition(type1);
			var end:Point = getPosition(type2);
			
			var angle:Number = Math.atan2(end.y - start.y, end.x - start.x) - Math.PI/2;	
			var offset:Point = Point.polar(_thickness, angle);
			
			// draw bar
			with (graphics){
				beginFill(this.fillColor, this.fillAlpha);
				lineStyle(this.lineThickness, this.lineColor, this.lineAlpha);
				
				moveTo(start.x + offset.x, start.y + offset.y);
				lineTo(end.x + offset.x, end.y + offset.y);
				lineTo(end.x - offset.x, end.y - offset.y);
				lineTo(start.x - offset.x, start.y - offset.y);
				lineTo(start.x + offset.x, start.y + offset.y);
				
				endFill();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mouseDownHandler(event:MouseEvent):void {
			updateTransform();
			
			super.mouseDownHandler(event);
			
			recordKeyInformation();
			
			baseMouse = endPoint.clone();
			baseMatrix = tool.calculatedMatrix;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function setPosition():void {
			// overridden to prevent default Control behavior
			// for these skew controls, drawing sets position
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseMove(event:MouseEvent):void {
			super.activeMouseMove(event);
			
			recordKeyInformation();
			
			tool.calculatedMatrix = baseMatrix;
			
			switch (mode) {
				
				case Y_AXIS:
					tool.transformByPoint(baseMouse, endPoint, TransformMode.SKEW_Y_AXIS);
					break;
				case X_AXIS:
					tool.transformByPoint(baseMouse, endPoint, TransformMode.SKEW_X_AXIS);
					break;
			}
			tool.update(false);
			
			keepWithinBounds();
		}
		
	}
}