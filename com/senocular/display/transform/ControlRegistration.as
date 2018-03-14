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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.senocular.events.TransformEvent;
	
	/**
	 * Displays and allows users to move the registration point being used by
	 * the Transform Tool's target instance.  The registration point is the
	 * point around which all transformations take place. 
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao
	 */
	public class ControlRegistration extends ControlInteractive {
		
		/**
		 * Determines whether or not the registration point can be moved
		 * by the user.  When true, the registration point can be moved.
		 * When false, it cannot.  This only restricts repositioning via
		 * mouse interaction.  The registration manager of a Transform
		 * Tool can still be used to modify the registration point used
		 * by a target object.
		 */
		public function get editable():Boolean {
			return _editable;
		}
		public function set editable(value:Boolean):void {
			_editable = value;
		}
		private var _editable:Boolean = true;
		
		/**
		 * Constructor for creating new ControlRegistration instances.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance.
		 */
		public function ControlRegistration(cursor:Cursor = null){
			super(cursor);
			initMouseEvents(this);
			doubleClickEnabled = true;
			lineColor = 0x000000;
			fillColor = 0xFFFFFF;
			addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
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
		override public function redraw(event:*):void {
			super.redraw(event);
			
			if (tool == null || tool.selectedItems.length == 0) 
				return;
			
			
			if (getVisible()) {
				this.visible = true;
				
				var loc:Point = getMaintainPoint(tool.registration);
				x = loc.x;
				y = loc.y;
			
			} else 
				this.visible = false;
			
		}
		
		/**
		 * Determines whether or not the control should be visible. When the
		 * Transform Tool is very small, and controls start to overlap with one
		 * another, ControlRegistration instances will hide themselves so that
		 * other controls can still be used without the registration point 
		 * getting in the way.
		 * @return True if the ControlRegistration instance should be visible;
		 * false if not.
		 */
		protected function getVisible():Boolean {
			if (Point.distance(tool.topRight, tool.topLeft) < width
			&&  Point.distance(tool.bottomLeft, tool.topLeft) < height) 
				return false;
			
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mouseDownHandler(event:MouseEvent):void {
			updateTransform();
			super.mouseDownHandler(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseMove(event:MouseEvent):void {
			if (_editable){
				super.activeMouseMove(event);
				
				// moves the registration point using the current mouse position
				tool.registration = endPoint.clone();
				// no need to calculate a transform
				// when only changing the registration point
				tool.update(false);
				
				withinBoundsMatrix = _tool.calculatedMatrix;
				prevX = _tool.x;
				prevY = _tool.y;
				var b:Rectangle = _tool.bounds;
				if (b)
					prevBounds = b.clone();
				
			}
		}
		
		/**
		 * Handler for the MouseEvent.DOUBLE_CLICK event. When double-clicked,
		 * a registration point will reset itself to its default location as
		 * defined by the (0,0) location in a target object's coordinate space.
		 */
		protected function doubleClickHandler(event:MouseEvent):void {
			if (_editable){
				
				tool.registration = tool.calculatedMatrix.transformPoint(new Point());
				tool.update();
			}
		}
		
	}
}