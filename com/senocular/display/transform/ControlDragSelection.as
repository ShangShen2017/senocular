/*
Copyright (c) 2016 Shuang

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
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.events.EventPhase;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class ControlDragSelection extends ControlInteractive {
		
		/**
		 * @private
		 */
		protected var isDrawing:Boolean;
		
		/**
		 * @private
		 */
		protected var orig:Point = new Point();
		
		/**
		 * @private
		 */
		protected var end:Point = new Point();
		
		/**
		 * @private
		 */
		protected var _mouseDownShape:Sprite;
		
		/**
		 * @private
		 */
		protected var _immediateSelection:Boolean;
		
		/**
		 * @private
		 */
		protected var _withRectangle:Boolean;
		
		/**
		 * When true
		 */
		public function get withRectangle():Boolean {
			return _withRectangle;
		}
		public function set withRectangle(value:Boolean):void {
			_withRectangle = value;
		}
		
		/**
		 * When true
		 */
		public function get immediateSelection():Boolean {
			return _immediateSelection;
		}
		public function set immediateSelection(value:Boolean):void {
			_immediateSelection = value;
		}
		
		/**
		 * 
		 */
		public function get mouseDownShape():Sprite {
			return _mouseDownShape;
		}
		public function set mouseDownShape(value:Sprite):void {
			if (_tool && _mouseDownShape != value) {
				if (_mouseDownShape)
					clearMouseEvents(mouseDownShape);
					
				_mouseDownShape = value;
				initMouseEvents(mouseDownShape);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set tool(value:TransformTool):void {
			super.tool = value;
			if (_mouseDownShape) {
				if (_tool) 
					initMouseEvents(mouseDownShape);
				else 
					clearMouseEvents(mouseDownShape);
				
			}
		}
		
		/**
		 * Constructor for creating new ControlDragSelection instances.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance.
		 * @author Shuang
		 */
		public function ControlDragSelection(cursor:Cursor=null) {
			super(cursor);
			_fillAlpha = 0;
			_lineColor = 0x000000;
			_lineThickness = 1;
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
			graphics.clear();
			
			if (isDrawing) {
				
				with (graphics) {
					beginFill(fillColor, fillAlpha);
					lineStyle(lineThickness, lineColor, lineAlpha);
					drawRect(orig.x, orig.y, end.x - orig.x, end.y - orig.y);
					endFill();
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function startSelection():void {
			// 
			var commonParent:DisplayObjectContainer = tool.commonParent;
			
			var rect1:Rectangle = getBounds(commonParent);
			
			var items:Array = _tool.items;
			var i:int = items.length;
			while (i--) {
				var target:DisplayObject = (items[i] as TransformItem).target;
				var rect2:Rectangle = target.getBounds(commonParent);
				
				// find the intersection of the two bounding boxes.
				var intersectionRect:Rectangle = rect1.intersection(rect2);
				
				if (intersectionRect.size.length > 0) {
					if (_withRectangle)
						tool.selectItem(target);
					else {
						var parentXformInvert:Matrix = (commonParent is Stage) ? commonParent.transform.matrix : commonParent.transform.concatenatedMatrix;
						parentXformInvert.invert();
						
						// calculate the transform for the display object relative to the common parent.
						var targetXform:Matrix = target.transform.concatenatedMatrix;
						targetXform.concat(parentXformInvert);
						
						// translate the target into the rect's space.
						targetXform.translate(-intersectionRect.x, -intersectionRect.y);
						
						// draw the target and extract its alpha channel into a color channel.
						var bd:BitmapData = new BitmapData(rect2.width, rect2.height, true, 0);
						bd.draw(target, targetXform);
						
						intersectionRect.x = 0;
						intersectionRect.y = 0;
						
						if (bd.hitTest(new Point(0, 0), 255, intersectionRect)) 
							tool.selectItem(target);
						
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mouseDownHandler(event:MouseEvent):void {
			updateTransform();
			super.mouseDownHandler(event);
			isDrawing = true;
			
			orig.x = mouseX;
			orig.y = mouseY;
			
			if (!tool.relative) 
				orig = transform.concatenatedMatrix.transformPoint(orig);
			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseUp(event:MouseEvent):void {
			// only handle events down to and including the target
			if (event.eventPhase != EventPhase.BUBBLING_PHASE){
				
				activeMouseEvent = null;
				cleanupActiveMouse();
			}
			
			isDrawing = false;
			
			tool.deselect();
			
			if (!_immediateSelection) 
				startSelection();
			
			redraw(null);
			
			tool.update();
			
			withinBoundsMatrix = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseMove(event:MouseEvent):void {
			super.activeMouseMove(event);
			
			end.x = mouseX;
			end.y = mouseY;
			
			if (!tool.relative) 
				end = transform.concatenatedMatrix.transformPoint(end);
			
			if (_immediateSelection)
				startSelection();
			
			redraw(null);
			
			tool.update(false);
		}
	}
	
}