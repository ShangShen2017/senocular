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
	
	/**
	 * Draws a border around the local coordinate space of the target object.
	 * ControlBorder styling does not support fill styles.
	 * @author Trevor McCauley
	 */
	public class ControlBorder extends Control {
		
		/**
		 * Constructor for creating new ControlBorder instances.
		 */
		public function ControlBorder(){
			this.mouseEnabled = false;
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			redraw(null);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(event:*):void {
			
			var tool:TransformTool = this.tool;
			if (tool == null || tool.selectedItems.length == 0) 
				return;
			
			
			var corner1:Point = getMaintainPoint(new Point(tool.topLeft.x, tool.topLeft.y));
			var corner2:Point = getMaintainPoint(new Point(tool.topRight.x, tool.topRight.y));
			var corner3:Point = getMaintainPoint(new Point(tool.bottomRight.x, tool.bottomRight.y));
			var corner4:Point = getMaintainPoint(new Point(tool.bottomLeft.x, tool.bottomLeft.y));
			
			with (graphics){
				clear();
				lineStyle(this.lineThickness, this.lineColor, this.lineAlpha);
				moveTo(corner1.x, corner1.y);
				lineTo(corner2.x, corner2.y);
				lineTo(corner3.x, corner3.y);
				lineTo(corner4.x, corner4.y);
				lineTo(corner1.x, corner1.y);
			}
		}
	}
}