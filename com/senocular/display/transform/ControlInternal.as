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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	/**
	 * ControlTransform is the base class for all ControlScale, ControlSkewBar, ControlRotate 
	 * classes and provides core functionality and properties. the original 
	 * parameters for individuals feel not logical relationship. 
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao 
	 */
	public class ControlInternal extends ControlRestrictBounds {
		
		/**
		 * A pixel-based offset (not percentage) for additional 
		 * positioning for the control on top of positioning.
		 */
		public function get offset():Point {
			return _offset;
		}
		public function set offset(value:Point):void {
			_offset = value;
		}
		private var _offset:Point;
		
		/**
		 *
		 */
		public function get positionType():String {
			return _positionType;
		}
		private var _positionType:String;
		
		/**
		 * Constructor for creating new ControlGrid instances.
		 * @param	positionType The 
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance. 
		 */
		public function ControlInternal(positionType:String, cursor:Cursor = null) {
			super(cursor);
			_positionType = positionType;
		}
		
		/**
		 *
		 */
		public function getPosition(positionType:String, offset:Point=null):Point {
			
			var tool:TransformTool = this.tool;
			if (tool == null || tool.selectedItems.length == 0) 
				return new Point(0, 0);
			
			if (offset == null) 
				offset = _offset;
			
			// transform the local positions into tool
			// positions 
			var position:Point = getMaintainPoint(tool[positionType]);
			
			// apply offset
			if (offset){
				
				var angle:Number;
				var m:Matrix = tool.calculatedMatrix;
				if (!isNaN(offset.x)){
					angle = MatrixTool.getRotationX(m, true);
					position.x += offset.x * Math.cos(angle);
					position.y += offset.x * Math.sin(angle);
				}
				if (!isNaN(offset.y)){
					angle = MatrixTool.getRotationY(m, true);
					position.x += offset.y * Math.sin(angle);
					position.y += offset.y * Math.cos(angle);
				}
			}
			
			return position;
		}
		
		/**
		 * Sets the position of the control to the current location returned
		 * by getPosition.
		 */
		protected function setPosition():void {
			var position:Point = getPosition(this.positionType);
			x = position.x;
			y = position.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(event:*):void {
			super.redraw(event);
			setPosition();
		}
		
	}
}