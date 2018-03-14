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
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a border around the bounding box of the target object in the
	 * coordinate space of its parent container. ControlBoundingBox styling
	 * does not support fill styles.
	 * @author Trevor McCauley
	 */
	public class ControlBoundingBox extends Control {
		
		/**
		 * Constructor for creating new ControlBoundingBox instances.
		 */
		public function ControlBoundingBox() {
			super();
			this.mouseEnabled = false;
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
			super.redraw(event);
			
			var tool:TransformTool = this.tool;
			if (tool == null || tool.selectedItems.length == 0) 
				return;
			
			
			var b:Rectangle = tool.selectionBounds;
			var corner1:Point = getMaintainPoint(new Point(b.x, b.y));
			var corner2:Point = getMaintainPoint(new Point(b.right, b.bottom));
			
			var minX:Number = corner1.x;
			var minY:Number = corner1.y;
			var maxX:Number = corner2.x;
			var maxY:Number = corner2.y;
			
			with (graphics){
				clear();
				lineStyle(this.lineThickness, this.lineColor, this.lineAlpha);
				
				moveTo(minX, minY);
				lineTo(maxX, minY);
				lineTo(maxX, maxY);
				lineTo(minX, maxY);
				lineTo(minX, minY);
			}
		}
	}
}